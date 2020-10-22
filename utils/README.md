# OF816 Utilities

## index.rb

Usage: index.rb <file.s> \[coverage.yml]

This will index the words appearing in an assembly source file
and output YAML on STDOUT containing entries for each word along
with the help text derived from comments preceding the word.

Help text is derived from comments of the form:
```
; H: ( -- ) example help text
; H: a second line
```

A word can be excluded from indexing if the word noindex
is found on the line containing the dword or dwordq macro
for the word:
```
dword MY_WORD,"MY-WORD" ; noindex
```

Test coverage data (see platforms/GoSXB) can be merged into
the output in order to be used by the covrep.rb utility and
a future documentation generator.

## index2md.rb

Usage: index2md.rb index.yml

Convert index.yml to markdown on stdout for word documentation.

Efforts are made to add emphasis to stack effects and intelligently
split separate semantics.

## covrep.rb

Usage: covrep.rb index.yml

This takes the output (redirected to a file) from index.rb
and produces a test coverage report, listing the covered and
uncovered word counts, the words that are not covered, and the
percentage of words that are covered.

Example:

```
Total words: 402
Covered words: 292
Uncovered words: 110
        SET-ORDER FORTH-WORDLIST CONTEXT GET-CURRENT GET-ORDER
        ALSO PREVIOUS SET-CURRENT ONLY SEAL
        ORDER DEFINITIONS .VERSION RESET-ALL BYE
        ABORT" ABORT UNUSED #IN COMPILE,
        UNALIGNED-L@ UNALIGNED-W@ UNALIGNED-L! UNALIGNED-W! 2>R
        N>R 2R> NR> 2R@ 2ROT
        <> U<= U> U>= <=
        AHEAD AGAIN WITHIN BETWEEN ?DO
        DNEGATE DABS D>S 2S>D (CR
        PAGE AT-XY SIGNUM U/MOD UD/MOD
        U* U# D.R D. U.0
        CMOVE CMOVE> COMPARE /STRING SEARCH
        WBFLIPS LBFLIPS LWFLIPS CPEEK WPEEK
        LPEEK CPOKE WPOKE LPOKE FCODE-REVISION
        FERROR SET-TOKEN GET-TOKEN RB@ RW@
        RL@ RB! RW! RL! $BYTE-EXEC
        BYTE-LOAD DUMP LEFT-PARSE-STRING PARSE-2INT SEARCH-WORDLIST
        $SEARCH $SOURCE-ID SOURCE-ID REFILL SHOWSTACK
        NOSHOWSTACK PARSE-NAME SLITERAL " COMPILE
        [COMPILE] WORDS (SEE) SEE (IS-USER-WORD)
        $VALUE :NONAME ;CODE WORDLIST VOCABULARY
        \ SAVE-INPUT $RESTORE-INPUT RESTORE-INPUT $FORGET
Coverage: 72%
```

## fs2asm.rb

Convert Forth source code to assembly language equivalent.

Please read the comments at the beginning of the program for usage.


