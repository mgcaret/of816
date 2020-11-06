\ *****************************************************************************
\ * Copyright (c) 2004, 2008 IBM Corporation
\ * All rights reserved.
\ * This program and the accompanying materials
\ * are made available under the terms of the BSD License
\ * which accompanies this distribution, and is available at
\ * http://www.opensource.org/licenses/bsd-license.php
\ *
\ * Contributors:
\ *     IBM Corporation - initial implementation
\ ****************************************************************************/


\ OF816 Changes: case-insensitive comparision

\ Modified by MAG for OF816
: ([IF])
  BEGIN
    BEGIN parse-word dup 0= WHILE
      2drop refill
    REPEAT

    2dup s" [IF]" string=ci IF 1 throw THEN
    2dup s" [ELSE]" string=ci IF 2 throw THEN
    2dup s" [THEN]" string=ci IF 3 throw THEN
    s" \" str= IF ['] \ execute THEN
  AGAIN
  ;

: [IF] ( flag -- )
  IF exit THEN
  1 BEGIN
    ['] ([IF]) catch 
    CASE
      1 OF 1+ ENDOF
      2 OF dup 1 = if 1- then ENDOF
      3 OF 1- ENDOF
    ENDCASE
    dup 0 <=
  UNTIL drop
; immediate

: [ELSE] 0 [COMPILE] [IF] ; immediate
: [THEN] ; immediate

\ Added by MG
: [IFDEF] parse-word $search dup 0<> if nip then postpone [IF] ; immediate
: [IFNDEF] parse-word $search dup 0<> if nip then 0= postpone [IF] ; immediate
