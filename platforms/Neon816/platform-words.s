; Platform support dictionary words for Neon816

dword     MS,"MS"
          stz   WR+2
          jsr   _popay
          sta   WR+1
          tya
          xba
          sep   #SHORT_A
          .a8
          sta   WR
          rep   #SHORT_A
          .a16
          tya
          and   #$00FF            ; do the first 1-255 ms
:         jsr   _mswait
          lda   WR
          ora   WR+1
          beq   :+                ; done if WR is zero
          jsr   _decwr
          lda   #$0100
          bra   :-
:         NEXT
eword
