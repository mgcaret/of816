
; Environmental Queries dictionary

; See config.inc for the options that control the conditionals here
; If max_search_order is > 0, then more entries or overridden entries
; can be placed into the environmental queries dictionary by doing:
; $ENV?-WL SET-CURRENT and then defining the new values (usually via
; VALUE or 2VALUE).

dstart "env"

; magic word in case user makes this the only dictionary in the search order.
; it will bail the user out by executing the FORTH word
.if max_search_order > 0
dword     XYZZY,"XYZZY",F_IMMED
.else
hword     XYZZY,"XYZZY",F_IMMED
.endif
          ENTER
          .dword FORTH
          EXIT
eword

.if env_query_level > 0

; Environmental queries
denvq     xCOUNTEDSTR,"/COUNTED-STRING",$FF
denvq     xHOLD,"/HOLD",word_buf_size
.if pad_size > 0
denvq     xPAD,"/PAD",pad_size
.endif
denvq     xADDRU,"ADDRESS-UNIT-BITS",8
denvq     xFLOORED,"FLOORED",$FFFFFFFF
denvq     xMAXCHAR,"MAX-CHAR",$FF
denvq     xMAXD,"MAX-D",$FFFFFFFF,$7FFFFFFF
denvq     xMAXN,"MAX-N",$7FFFFFFF
denvq     xMAXU,"MAX-U",$FFFFFFFF
denvq     xMAXUD,"MAX-UD",$FFFFFFFF,$FFFFFFFF
denvq     xRSTKC,"RETURN-STACK-CELLS",64
denvq     xSTKC,"STACK-CELLS",64
.if env_query_level > 1
denvq     xCORE,"CORE",$FFFFFFFF
denvq     xEXCEPTION,"EXCEPTION",$FFFFFFFF
denvq     xEXCEPTION_EXT,"EXCEPTION-EXT",$FFFFFFFF
.endif
.if include_fcode
denvq     xFCODE,"FCODE",$FFFFFFFF
.endif
.if max_search_order > 0
.if env_query_level > 1
denvq     xSEARCH_ORDER,"SEARCH-ORDER",$FFFFFFFF
denvq     xSEARCH_ORDER_EXT,"SEARCH-ORDER-EXT",$FFFFFFFF
.endif
denvq     xWORDLISTS,"WORDLISTS",max_search_order
.endif

.endif
dend
