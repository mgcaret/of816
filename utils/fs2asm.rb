#!/usr/bin/ruby

# This program converts Forth source code colon definitons to OF816 assembly-language
# dictionary entries suitable for assembling with ca65.
#
# It is, in effect, a Forth compiler in its own right.
#
# Usage: fs2asm.rb index1.yaml [index2.yaml ...] forth-source.fs
# Outputs the results on stdout.
#
# The index files are generated with index.rb, and should reflect all of the dictionaries
# present in the system that will be used by the input Forth code or may have label
# collisions.

# As a trivial example, this source code:
#
# \ output boolean value as text
# : .bool ( f - )
#   true if
#     s" true"
#   else
#     s" false"
#   then
#   type
# ;
#
# is converted to:
#
# ; output boolean value as text
# dword     DOT_BOOL,".bool"
#           ENTER
#           ; ( f - )
#           .dword TRUE
#           .dword _IF            ; IF
#           .dword l01            ; false branch
#           SLIT   "true"
#           .dword _JUMP
#           .dword l02
# l01:                            ; ELSE
#           SLIT   "false"
# l02:                            ; THEN
#           .dword TYPE
#           EXIT
# eword

# Features supported outside of colon definitions:
#
# The input number base can be changed with DECIMAL HEX BINARY and OCTAL.
#
# There is a basic stack that can contain numbers or labels.
# numbers may be placed on the stack in the usual fashion, and labels can be placed with
# ' (single-quote/tick).
# They can be used within definitions via LITERAL or COMPILE,
# no arithmetic is supported at this time.
#
# Words may be changed to headerless and back to normal with HEADERS and HEADERLESS.
 
# Unsupported items:
#
# Setting flags on words.
#
# RECURSE $HEX( TO and END-CODE
# quotations: [: and ;]
# no-name and temporary definitions: :NONAME :TEMP

# Bugs:
#
# Things that don't match words are silently converted into numbers without validation


require 'yaml'

@LABEL_CHARS = 10
@OP_CHARS = 7
@PARM_CHARS = 15

def emit_comment(comment)
  if @in_colon
    @asm += "#{" " * @LABEL_CHARS}; #{comment}\n"
  else
    @asm += "; #{comment}\n"
  end
end

def emit_line(label = '', opcode = '', parm = '', comment = nil)
  l = label || ''
  line = "%-#{@LABEL_CHARS}s%-#{@OP_CHARS}s%-#{@PARM_CHARS}s%s" % [
    label != '' ? "#{l}:" : '',
    "#{opcode} ",
    "#{parm}",
    comment ? "; #{comment}" : ''
  ]
  @asm += "#{line.rstrip}\n"
end

def emit_def_start(label, fname, flags = nil, comment = nil)
  wmacro = @headers ? 'dword' : 'hword'
  fn = fname
  if fname.include?('"')
    fn = fname.gsub(/"/, "'")
    wmacro += 'q'
  end
  line = "%-#{@LABEL_CHARS}s%-#{@OP_CHARS}s%-#{@PARM_CHARS}s%s" % [
    "#{wmacro} ",
    "#{label},\"#{fn}\"#{flags ? ",#{flags}" : ''} ",
    '',
    comment ? "; #{comment}" : ''
  ]
  @asm += "#{line.rstrip}\n"
end

def emit_def_end
  @asm += "eword\n"
end

def emit_dword(label, comment = nil)
  emit_line('', '.dword', label, comment)
end

# consume a character from the input source
def consume
  c = @fs[@inptr]
  @inptr += 1 if c
  return c
end

# Skip blanks, consume characters until the next one is a blank.
# For the purposes of this function, anything ASCII 32 (" ") or less is a blank (including
# newlines).  Discard the final blank and return the consumed characters
def parse_word
  consumed = ""
  while c = consume
    if c.ord > 32
      @inptr -= 1 # putback
      break
    end
  end
  while c = consume
    break if c.ord <= 32
    consumed += c
  end
  return consumed
end

# Consume characters until we reach newline or char.  Discard the final newline or char
# and return the consumed characters
def parse(char = " ")
  consumed = ""
  while c = consume
    break if c == char || c == "\n"
    consumed += c
  end
  return consumed
end

def label_exist?(label)
  @dictionary.map {|_k, v| v['label']}.include?(label)
end

def to_label(str)
  label = str.upcase.tr('#$<>()', 'ndlglr')
  label.gsub!(/\!/, '_STORE_')
  label.gsub!(/\@/, '_AT_')
  label.gsub!(/\&/, '_AND_')
  label.gsub!(/\^/, 'c')
  label.gsub!(/\*/, '_STAR_')
  label.gsub!(/\;/, '_SEMI_')
  label.gsub!(/\:/, '_COLON_')
  label.gsub!(/\?/, 'q')
  label.gsub!(/\'/, 'q')
  label.gsub!(/\"/, 'Q')
  label.gsub!(/\//, '_SLASH_')
  label.gsub!(/\\/, '_BACKSLASH_')
  label.gsub!(/\./, '_DOT_')
  label.gsub!(/\,/, '_COMMA_')
  label.gsub!(/\+/, '_PLUS_')
  label.gsub!(/\-/, '_MINUS_')
  label.gsub!(/\=/, '_EQUAL_')
  label.tr!('^A-Za-z0-9', '_')
  label.gsub!(/_+/, '_')
  label.gsub!(/^_+/, '')
  label.gsub!(/_+$/, '')
  if label_exist?(label)
    label += "_00"
    while label_exist?(label)
      label.next!
    end
  end
  return label 
end

def l_label
  @lserial += 1
  "l%02d" % @lserial
end

# consume a comment and emit as assembler comment
def f_slash_comment
  emit_comment(parse("\n"))
end

def f_paren_comment
  emit_comment("( #{parse(')')})")
end

# Process colon definitions
def f_colon
  name = parse_word
  unless name && name != ''
    abort("expecting name for colon definition")
  end
  label = to_label(name)
  if @dictionary.key?(name)
    emit_comment("WARNING: #{name} is not unique, old def no longer available")
  end
  @dictionary[name] = {
    "label" => label
  }

  emit_def_start(label, name)
  emit_line('', 'ENTER')
  @in_colon = true
  @lserial = 0
  while @in_colon
    word = parse_word.upcase
    next if word == ""
    if @dictionary[word] && @dictionary[word]['flags'] && @dictionary[word]['flags'].include?('F_IMMED')
      if @macros.key?(word)
        @macros[word].call
      else
        abort("immediate word #{word} does not have matching macro")
      end
    elsif @dictionary[word]
      emit_dword(@dictionary[word]['label'])
    elsif @macros.key?(word)
      @macros[word].call
    else
      emit_line('', 'ONLIT', word.to_i(@base))
    end
  end    
end

def f_semicolon
  abort('; while not in definition') unless @in_colon
  emit_line('', 'EXIT')
  emit_def_end
  emit_line
  @in_colon = false
  abort("control-flow stack not empty") unless @cflow.empty?
end

def f_s_quote
  abort('S" while not in definition') unless @in_colon
  str = parse('"')
  emit_line('', 'SLIT', "\"#{str}\"")  
end

def f_dot_quote
  abort('." while not in definition') unless @in_colon
  s_quote
  emit_dword('TYPE')
end

def f_abort_quote
  s_quote
  emit_dword('_ABORTQ')
end

def f_left_square_bracket
  @in_colon = false
end

def f_right_square_bracket
  @in_colon = true
end

def f_ahead(comment = nil)
  abort('AHEAD outside of definition') unless @in_colon
  l = l_label
  emit_dword('_JUMP', comment || 'AHEAD')
  emit_dword(l)
  @cflow.push({d: :orig, l: l})
end

def f_if
  abort('IF outside of definition') unless @in_colon
  l = l_label
  emit_dword('_IF', 'IF')
  emit_dword(l, "false branch")
  @cflow.push({d: :orig, l: l})
end

def f_else
  abort('ELSE outside of definition') unless @in_colon
  l = l_label
  emit_dword('_JUMP')
  emit_dword(l)
  orig = @cflow.pop
  abort('ELSE control flow mismatch') if orig[:d] != :orig
  emit_line(orig[:l], '', '','ELSE')
  @cflow.push({d: :orig, l: l})
end

def f_then
  abort('THEN outside of definition') unless @in_colon
  orig = @cflow.pop
  abort('THEN control flow mismatch') if orig[:d] != :orig
  emit_line(orig[:l], '', '','THEN')
end

def f_begin
  abort('BEGIN outside of definition') unless @in_colon
  l = l_label
  emit_line(l, '', '','BEGIN')
  @cflow.push({d: :dest, l: l})
end

def f_while
  abort('WHILE outside of definition') unless @in_colon
  emit_dword('_IF', 'WHILE')
  l = l_label
  emit_dword(l)
  dest = @cflow.pop
  @cflow.push({d: :orig, l: l})
  @cflow.push(dest)
end

def f_until
  abort('UNTIL outside of definition') unless @in_colon
  dest = @cflow.pop
  abort('UNTIL control flow mismatch') if dest[:d] != :dest
  emit_dword('_IF', 'UNTIL')
  emit_dword(dest[:l])
end

def f_repeat
  abort('REPEAT outside of definition') unless @in_colon
  dest = @cflow.pop
  abort('REPEAT control flow mismatch (dest)') if dest[:d] != :dest
  emit_dword('_JUMP', 'REPEAT (dest)')
  emit_dword(dest[:l])
  orig = @cflow.pop
  abort('REPEAT control flow mismatch (orig)') if orig[:d] != :orig
  emit_line(orig[:l])
end

def f_again
  abort('AGAIN outside of definition') unless @in_colon
  dest = @cflow.pop
  abort('AGAIN control flow mismatch') if dest[:d] != :dest
  emit_dword('_JUMP', 'AGAIN')
  emit_dword(dest[:l])  
end

def f_do
  abort('DO outside of definition') unless @in_colon
  emit_dword('_DO', 'DO')
  ahead('to LEAVE target')
  l = l_label
  emit_line(l, '', '', '+LOOP target')
  @cflow.push({d: :loop, l: l})
end

def f_qdo
  abort('DO outside of definition') unless @in_colon
  emit_dword('_QDO', '?DO')
  ahead('to LEAVE target')
  l = l_label
  emit_line(l, '', '', '+LOOP target')
  @cflow.push({d: :loop, l: l})
end

def f_ploop
  abort('+LOOP outside of definition') unless @in_colon
  emit_dword('_PLOOP', '+LOOP')
  lp = @cflow.pop
  abort('LOOP/+LOOP control flow mismatch (target)') if lp[:d] != :loop
  emit_dword(lp[:l], 'to +LOOP target')
  orig = @cflow.pop
  abort('LOOP/+LOOP control flow mismatch (LEAVE)') if orig[:d] != :orig
  emit_line(orig[:l], '', '','LEAVE target')
  emit_dword('UNLOOP')
end

def f_loop
  abort('LOOP outside of definition') unless @in_colon
  emit_dword('ONE')
  f_ploop
end

def f_case
  abort('CASE outside of definition') unless @in_colon
  emit_dword('_SKIP2', 'CASE')
  l = l_label
  @cflow.push({d: :case, l: l})
  emit_line(l, '', '', 'matched case target')
  ahead('to end of CASE')
end

def f_of
  abort('OF outside of definition') unless @in_colon
  l = l_label
  emit_dword('_OF', 'OF')
  @cflow.push({d: :of, l: l})
  emit_dword(l, 'no match branch')
end

def f_endof
  abort('ENDOF outside of definition') unless @in_colon
  ot = @cflow.pop
  abort('ENDOF control flow mismatch (OF)') if ot[:d] != :of
  ct = @cflow[-2] # matched case target
  abort('ENDOF control flow mismatch (matched CASE)') if ct[:d] != :case
  emit_dword('_JUMP', 'ENDOF (matched if we got here)')
  emit_dword(ct[:l])
  emit_line(ot[:l])
end

def f_endcase
  abort('ENDCASE outside of definition') unless @in_colon
  emit_dword('DROP', 'ENDCASE')
  at = @cflow.pop
  abort('ENDCASE control flow mismatch (failed match jump)') if at[:d] != :orig
  abort('ENDCASE control flow mismatch (CASE)') if @cflow.pop[:d] != :case
  emit_line(at[:l])
end

def f_tick
  abort('BUG: \' macro executed inside definition') if @in_colon
  w = parse_word.upcase
  abort("#{w}?") unless @dictionary.key?(w)
  @stack.push(@dictionary[w]['label'])
end

def f_ctick
  abort('[\'] outside of definition') unless @in_colon
  w = parse_word.upcase
  abort("#{w}?") unless @dictionary.key?(w)
  l = @dictionary[w]['label']
  emit_line('', 'ONLIT', l, "' #{w}")
end

def f_cchar
  abort('[CHAR] outside of definition') unless @in_colon
  c = parse_word
  emit_line('', 'ONLIT', c.ord, "[CHAR] #{c}")
end

def f_ascii
  c = parse_word
  if @in_colon
    emit_line('', 'ONLIT', c.ord, "ASCII #{c}")
  else
    @stack.push(c.ord)
  end
end

def f_control
  c = parse_word
  if @in_colon
    emit_line('', 'ONLIT', c.ord & 0x1F, "CONTROL #{c}")
  else
    @stack.push(c.ord & 0x1F)
  end
end

def f_ccompile
  abort('[COMPILE] outside of definition') unless @in_colon
  w = parse_word.upcase
  abort("#{w}?") unless @dictionary.key?(w)
  l = @dictionary[w]['label']
  emit_dword('_COMP_LIT', '[COMPILE]')
  emit_dword(l)
end

def f_literal
  abort('LITERAL outside of definition') unless @in_colon
  emit_line('', 'ONLIT', @stack.pop)
end

def f_2literal
  abort('LITERAL outside of definition') unless @in_colon
  n2 = @stack.pop
  n1 = @stack.pop
  emit_line('', 'ONLIT', n1)
  emit_line('', 'ONLIT', n2)  
end

def f_postpone
  abort('POSTPONE outside of definition') unless @in_colon
  w = parse_word.upcase
  abort("#{w}?") unless @dictionary.key?(w)
  l = @dictionary[w]['label']
  if @dictionary[w]['flags'] && @dictionary[w]['flags'].include?('F_IMMED')
    emit_dword(l, 'POSTPONE (imm)')
  else
    emit_dword('_COMP_LIT', 'POSTPONE')
    emit_dword(l)
  end
end

def f_compile
  abort('COMPILE outside of definition') unless @in_colon
  emit_dword('_COMP_LIT', 'COMPILE')
end

def f_dnum
  @stack.push(parse_word.to_i(10))
  f_literal if @in_colon
end

def f_hnum
  @stack.push(parse_word.to_i(16))
  f_literal if @in_colon
end

def f_onum
  @stack.push(parse_word.to_i(8))
  f_literal if @in_colon
end

def f_binary
  @base = 2
end

def f_octal
  @base = 8
end

def f_decimal
  @base = 10
end

def f_hex
  @base = 16
end

def f_semis
  abort(';CODE outside of definition') unless @in_colon
  emit_line('', 'CODE') 
end

def f_does
  abort('DOES> outside of definition') unless @in_colon
  f_semis
  emit_line('', 'jsl', 'f:_does')
  emit_line('', 'ENTER')
  emit_dword('RPLUCKADDR')
  emit_dword('INCR') 
end

def f_compilecomma
  abort('COMPILE, outside of definition') unless @in_colon
  emit_dword(@stack.pop)
end

def f_headers
  abort('HEADERS inside of definition') if @in_colon
  @headers = true
  emit_comment('headers')
  emit_line
end

def f_headerless
  abort('HEADERLESS inside of definition') if @in_colon
  @headers = false
  emit_comment('headerless')
  emit_line
end


# Macros. For words that are normally immediates and other utility things, is searched:
# - for any and all words outside of a colon definition
# - whenever a word inside a colon definition is flagged as immediate
# - before attempts to convert an unfound word to a number
@macros = {
  '\\' => method(:f_slash_comment),
  '(' => method(:f_paren_comment),
  '.(' => method(:f_paren_comment),
  ':' => method(:f_colon),
  ';' => method(:f_semicolon),
  'S"' => method(:f_s_quote),
  '."' => method(:f_dot_quote),
  '"' => method(:f_s_quote), # TODO: implement IEEE 1275-1994/toke version of this
  'ABORT"' => method(:f_abort_quote),
  '[' => method(:f_left_square_bracket),
  ']' => method(:f_right_square_bracket),
  'AHEAD' => method(:f_ahead),
  'IF' => method(:f_if),
  'ELSE' => method(:f_else),
  'THEN' => method(:f_then),
  'BEGIN' => method(:f_begin),
  'WHILE' => method(:f_while),
  'UNTIL' => method(:f_until),
  'REPEAT' => method(:f_repeat),
  'AGAIN' => method(:f_again),
  'DO' => method(:f_do),
  'QDO' => method(:f_qdo),
  '+LOOP' => method(:f_ploop),
  'LOOP' => method(:f_loop),
  'CASE' => method(:f_case),
  'OF' => method(:f_of),
  'ENDOF' => method(:f_endof),
  'ENDCASE' => method(:f_endcase),
  'RECURSIVE' => ->{}, # no-op, it is always findable with this program
  '\'' => method(:f_tick),
  '[\']' => method(:f_ctick),
  '[CHAR]' => method(:f_cchar),
  'ASCII' => method(:f_ascii),
  'CONTROL' => method(:f_control),
  '[COMPILE]' => method(:f_ccompile),
  'LITERAL' => method(:f_literal),
  '2LITERAL' => method(:f_2literal),
  'POSTPONE' => method(:f_postpone),
  'COMPILE' => method(:f_compile),
  'H#' => method(:f_hnum),
  'D#' => method(:f_dnum),
  'O#' => method(:f_onum),
  'BINARY' => method(:f_binary),
  'OCTAL' => method(:f_octal),
  'DECIMAL' => method(:f_decimal),
  'HEX' => method(:f_hex),
  ';CODE' => method(:f_semis),
  'DOES>' => method(:f_does),
  'COMPILE,' => method(:f_compilecomma),
  'HEADERS' => method(:f_headers),
  'HEADERLESS' => method(:f_headerless),
}

# This is the sum of all index files loaded on the command line
@dictionary = {}

while ARGV.count > 1
  yfile = ARGV.shift
  if File.readable?(yfile)
    @dictionary.merge!(YAML.load(File.read(yfile)))
  end
end

src_file = ARGV.shift

unless src_file && File.readable?(src_file)
  abort("Cannot read source file!")
end

@base = 16
@fs = File.read(src_file).chars
@asm = ""
@inptr = 0
@in_colon = false
@cflow = []
@stack = []
@lserial = 0
@headers = true
while @inptr < @fs.length
  word = parse_word.upcase
  next if word == ""
  if @macros.key?(word)
    @macros[word].call
  elsif @dictionary.key?(word)
    if word.to_i(@base).to_s(@base).upcase == word.upcase
      @stack.push(word.to_i(@base))
    else
      abort("#{word}: words outside of colon definitions must be macros")
    end    
  else
    @stack.push(word.to_i(@base))
  end
end
abort("data stack not empty: #{@stack.inspect}") unless @stack.empty?

puts @asm
