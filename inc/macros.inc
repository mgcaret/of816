; Macro library for OF816.  Contains macros for hand-compiled Forth code and common
; ops used within primitives.   Also contains macros for building dictionaries.

; Config/build macros

.macro PLATFORM_INCLUDE file
  .if .strlen(PLATFORM) > 0
    .out .sprintf("Including text platforms/%s/%s", PLATFORM, file)
    .include .sprintf("platforms/%s/%s", PLATFORM, file)
  .endif
.endmacro

.macro PLATFORM_INCBIN file
  .if .strlen(PLATFORM) > 0
    .out .sprintf("Including binary platforms/%s/%s", PLATFORM, file)
    .incbin .sprintf("platforms/%s/%s", PLATFORM, file)
  .endif
.endmacro

; General macros & defs
.define SHORT_A %00100000
.define SHORT_I %00010000

;.macro LDAY val
;  ldy   .loword(val)
;  lda   .hiword(val)
;.endmacro

; Forth macros

; Enter inner interpreter with 32-bit absolute addresses
.macro  ENTER
  jsl _enter
.endmacro

.macro EXIT
  .dword _exit_next-1
.endmacro

.macro CODE
  .dword _exit_code-1
.endmacro

.macro NEXT
  jmp _next
.endmacro

.macro LNEXT
  jml f:_next
.endmacro

.macro PUSHNEXT
  jmp _next::fast_num
.endmacro

.macro LPUSHNEXT
  jml f:_next::fast_num
.endmacro

.macro RUN
  jmp _next::run
.endmacro

.macro LRUN
  jml f:_next::run
.endmacro


; This version always stores one or two cell-sized objects
.macro NLIT num
  .if .const(num)
    .if .hiword(num) > 0 || no_fast_lits
      .dword _LIT
    .endif
    .word .loword(num)
    .word .hiword(num)
  .else
    .dword _LIT
    .dword num
  .endif
.endmacro

; This version will use the most optimal
; storage for the literal in question
.macro ONLIT num
  .if .const(num)
    .if .hiword(num) > 0 ; big numbers are always expensive
      .dword _LIT
      .word .loword(num)
      .word .hiword(num)      
    .elseif no_fast_lits ; if no fast literals, right-size it
      .if .hibyte(num) > 0
        .dword _WLIT
        .word num
      .else
        .dword _CLIT
        .byte num
      .endif
    .else ; fast literals are the cheapest when available
      .word .loword(num)
      .word .hiword(num)
    .endif
  .else
    NLIT num  ; non-const expressions get a cell
  .endif
.endmacro

.macro JUMP target
  .dword _JUMP
  .dword target
.endmacro

.macro BRANCH target
  .dword _BRANCH
  .addr target-*
.endmacro

.if 0
; Macro for a string literal ( -- c-addr u )
.macro OLDSLIT str
  .local target,addr
  JUMP target
addr:
  .byte str
target:
  NLIT addr
  NLIT .strlen(str)
.endmacro
.endif

.macro SLIT str
  .dword _SLIT
  .dword .strlen(str)
  .byte str
.endmacro

; Macro for a counted string literal ( -- c-addr )
.macro CSLIT str
  .local target,addr
  JUMP target
addr:
  .byte .strlen(str)
  .byte str
target:
  NLIT addr
.endmacro

.macro FCONSTANT value
  ldy #.loword(value)
  lda #.hiword(value)
  PUSHNEXT
.endmacro

; Can't be used in ROMable code
.macro FVARIABLE value
  jsl _pushda
  val: .dword value
.endmacro

; Can't be used in ROMable code
.macro FVALUE value
  jsl _pushconst
  val: .dword value
.endmacro

; Can't be used in ROMable code
.macro DEFER adr
  jsl _deferred
  val:
  .ifblank adr
    .dword _unimpl
  .else
    .dword adr
  .endif
.endmacro

.macro FFIELD offset
  jsl _field
  .dword offset
.endmacro

NUM_SYSVARS .set 0

.macro DEF_SYSVAR num,name
  .assert num=NUM_SYSVARS, error, "System variable defined out-of-order"
  name = num*4
  NUM_SYSVARS .set NUM_SYSVARS+1
.endmacro

.macro SYSVAR num
  jsl _sysvar
  .dword num
.endmacro

.macro SYSVAR_INIT name  
  .assert .sizeof(name)=NUM_SYSVARS*4,error,.sprintf("SYSVAR_INIT: size incorrect, should be %i dwords",NUM_SYSVARS)
.endmacro

.macro FSTR str
  .local target,thestr
  ldy #<.loword(thestr)
  lda #>.hiword(thestr)
  jsr _pushay
  ldy #<.strlen(str)
  lda #>.strlen(str)
  jsr _pushay
  bra target
  thestr: .byte str
  target:
.endmacro

.macro TRACE name
  .ifblank name
    jsr _named_trace
    .byte name
  .else
    jsr _word_trace
  .endif
.endmacro

; Dictionary structure macros

; Dictionary format:

; Bytes Purpose
; Header  (scope H_<name>)
; 4     Link to previous (0=end of dictionary), not present for "headerless" words
; 1     Name Length, high bit always set (max=127)
; n     Name (high bits clear), if present
; 1     Flags
;       b7 - Immediate
;       b6 - Compile-only
;       b0 - Smudge
; Code  (scope <name>)

.define F_IMMED %10000000         ; immediate
.define F_CONLY %01000000         ; compile-only
.define F_PROT  %00100000         ; begin system protection (from FORGET, etc.)
.define F_TEMPD %00010000         ; word initiates or finishes temporary definition
.define F_SMUDG %00001000         ; smudged, invisible in search

.define NAMEMSK %01111111         ; name length mask

.macro dstart dictname
  .ifdef c_dict
    .error "%s dictionary not closed",.string(c_dict)
  .endif
  .define c_dict dictname
  .ifndef __dstart
    __dstart = 0
  .endif
  .define l_dword __dstart        ; last defined word
  .out .sprintf("Start of dictionary: %s",c_dict)
.endmacro

.macro dhead link,dname,fname
  .if print_dict && .strlen(fname) > 0
    .if .const(*)
      .out .concat(fname, .sprintf(" def at $%x", *))
    .else
      .out .concat(fname, " def starts")
    .endif
  .elseif print_dict
    .if .const(*)
      .out .concat(.string(dname), .sprintf(" def at $%x", *))
    .else
      .out .concat(.string(dname), " def starts")
    .endif  
  .endif
  .proc .ident(.sprintf("H_%s",.string(dname)))
    .if .strlen(fname) > 0
      .dword link
      .byte .strlen(fname)|$80
      .byte fname
    .else
      .byte $80
    .endif
  .endproc  
.endmacro

.macro dword dname,fname,flags
  .ifdef c_dword
    .error .sprintf("%s def not closed",.string(c_dword))
  .endif
  .if .strlen(fname) > 0
    .define c_dword .ident(.sprintf("H_%s",.string(dname)))
  .endif
  dhead l_dword,dname,fname
  .proc dname
    .if print_dict && .const(*)
      .out .sprintf("    xt at $%x", *)
    .endif
    ; flag byte here so that XT is code addr - 1
    .ifblank flags
      .byte F_PROT
    .else
      .byte flags|F_PROT
    .endif
  code:
  .if trace
    wdm $80 ; for emulator debugger
  .endif
.endmacro

.macro hword dname,fname,flags
  .if no_headerless
    .ifblank flags
      dword dname,fname
    .else
      dword dname,fname,flags
    .endif  
  .else
    .ifblank flags
      dword dname,""
    .else
      dword dname,"",flags
    .endif
  .endif
.endmacro

.macro dwordq dname,fname,flags
  .charmap $27,$22 ; temporarily map single quote to double quote
  .ifblank flags
    dword dname,fname
  .else
    dword dname,fname,flags
  .endif
  .charmap $27,$27 ; unmap
.endmacro

.macro hwordq dname,fname,flags
  .charmap $27,$22 ; temporarily map single quote to double quote
  .ifblank flags
    hword dname,fname
  .else
    hword dname,fname,flags
  .endif
  .charmap $27,$27 ; unmap
.endmacro

.macro dchain dname
  .undefine l_dword
  .define l_dword dname
.endmacro

.macro eword
  .endproc
  .ifdef c_dword
    dchain c_dword
    .undefine c_dword
  .endif
.endmacro

.macro denvq dname,fname,value,value2
  dword dname,fname
  .ifblank value2
    jsl _pushvalue
    .dword value
  .else
    jsl _push2value
    .dword value2
    .dword value
  .endif
  eword
.endmacro

.macro dend
  .out .sprintf("End of dictiomnary: %s",c_dict)
  .ident(.sprintf("LAST_%s",c_dict)) = l_dword
  .undef c_dict
  .undef l_dword
.endmacro

; outside-of-dictionary headerless words
; mainly to support FCode features
.macro xdword dname,flags
  .proc .ident(.sprintf("H_%s",.string(dname)))
    .byte $80
  .endproc  
  .proc dname
    .ifblank flags
      .byte F_PROT
    .else
      .byte flags|F_PROT
    .endif
    code:
.endmacro

.macro exdword
  .endproc
.endmacro

; FCode macros
.define FC_ROMFLAG $80000000
.define FC_IMMFLAG $80000000

; These get around stupid address size calculation probs in the linker
.macro FCROM addr
  .faraddr addr
  .byte .hibyte(.hiword(FC_ROMFLAG))
.endmacro

.macro FCIMM addr
  .faraddr addr
  .byte .hibyte(.hiword(FC_IMMFLAG))
.endmacro

