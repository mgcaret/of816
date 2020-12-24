; Apple IIgs Configuration File

; This platform uses it...
PLATFORM_INCLUDE "platform-config.inc"

; *** options ***

; Set this to a nonzero value if any code will run out of bank 0.  If not set, then
; numeric literals <= $0000FFFF will use the "fast literal" mode, getting on the
; stack faster and using less memory.
; We run out of bank 0 on the IIgs, so this is set
.define no_fast_lits 1

; Set this to the size of the terminal input buffer.  This will be dynamically allocated
; when the system starts.  If command line history is enabled, several of these may be
; allocated at any given time.  IEEE 1275 requires that it be 128 chars.
.define tib_size 128

; Set this to the number of bytes in the PAD.  This is not required by IEEE 1275 and can
; be turned off with 0, saving a few bytes.  ANSI X3J14-1994 requires at least 84 chars
; (bytes in our case) in the pad if it is present
.define pad_size $100

; Set this to the byte size of the WORD buffer.  IEEE 1275 requires it to be (>=) 80.
; this buffer is shared with the pictured numeric output, which IEEE 1275 requires to
; be able to hold (>=) 66 characters.
.define word_buf_size 80

; Set this to a nonzero value to include FCode features (see IEEE 1275).  This will
; cause the system size to increase by ~6K and also increase memory usage.
; The FCode evaluator supports most of the non-Device Tree FCode numbers, which can be
; added later via FCode or source in order to build an Open Firmware implementation on
; top of OF816.
.define include_fcode 1

; Set this to the number of word lists that may be in the search order.  This number
; is required by ANSI X3J14-1994 to be 8 or greater if search order words are implemented.
; If this is set to 0, search order words are not included and about 1K is saved from
; the system size.
.define max_search_order 8

; IEEE 1275 specifies that certain words where interpretation semantics are not defined
; by ANSI X3J14-1994 must trigger a temporary definition outside of data space in order
; to provide interpretation semantics equivalent to what occurs in a compiled word.
; (e.g. '10 0 do i . loop' works outside of a definition)
; set this to the number of bytes allowed for such a temporary definition (512 =~ 128
; cells).  The memory used for a temporary definition is allocated from the heap, and is
; *not* bounds-checked during creation of the temporary definition.
.define max_tempdef 512

; SEE is a large complicated word.  Omitting it saves 500 bytes.
.define include_see 1

; quotations are non-standard in ANS Forth and IEEE 1275, but may be useful
.define enable_quotations 1

; IEEE 1275 declines to identify what ENVIRONMENT? should return.  ANS Forth gives
; specifics, but Forth 2012 deprecates detecting wordlists through environmental queries
; set this to 0 to include no environmental queries (ENVIRONMENT? always returns false)
; set this to 1 to include everything but the word list entries
; set this to 2 to include all of them
; note that the routines to access the environmental queries dictionary are not omitted,
; even when env_query_level is zero.  As long as max_search_order is nonzero it is 
; possible to add items to the environmental query dictionary
.define env_query_level 0

; UNALIGNED-[LW][!@] words are specified by IEEE 1275 for the user interface only (not
; FCode).  In general these are redundant on the '816 because all accesses are unaligned,
; and in fact are defined as aliases to the normal versions of these.
; set this to 0 to exclude them, saving a few bytes.
.define unaligned_words 0

; *** debug options ***

.define trace 0       ; requires emulator cooperation via WDM instruction
.define print_dict 0  ; output word addresses and XTs during assembly

.if trace
  .define no_headerless 1
.else
  .define no_headerless 0 ; set to 1 to compile headers for all words for debugging
.endif
