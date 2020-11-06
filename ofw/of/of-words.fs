hex

: $banner
  ." Open Firmware for OF816 by Michael Guidero" cr
  ." Portions (c) IBM Corp. (https://github.com/aik/SLOF)"
;

db" OF words and values"

810000 value load-base
0 0 2value boot-device
0 0 2value boot-file
0 0 2value diag-device
0 0 2value diag-file
0 0 2value boot-command
false value diag-switch?
: diagnostic-mode? diag-switch? ;
false value auto-boot?

0 0 2value use-nvramrc
false value use-nvramrc?

0 0 2value input-device
0 0 2value output-device
variable stdin
variable stdout
d# 80 value screen-#columns
d# 25 value screen-#rows

0 value security-mode
0 0 2value security-password
0 value security-#badlogins

0 value selftest-#megs

false value $did-banner?
false value oem-logo?
0 0 2value oem-logo
false value oem-banner?
0 0 2value oem-banner

: help ." Please visit https://github.com/mgcaret/of816 " cr ;

: (unsup) ." (unsup) feature" cr d# -21 throw ;

\ All TODO
: boot (unsup) ;
: setenv (unsup) ;
: $setenv (unsup) ;
: printenv (unsup) ;
: set-default (unsup) ;
: set-defaults (unsup) ;
: nodefault-butes (unsup) ;

\ All TODO
: nvedit (unsup) ;
: nvstore (unsup) ;
: nvquit (unsup) ;
: nvrecover (unsup) ;
: nvrun (unsup) ;

\ All TODO
: install-console ( unsup ) ;
: input (unsup) ;
: output (unsup) ;
: io (unsup) ;

\ TODO
: password (unsup) ;

\ TODO
: test parse-word 2drop ;
: test-all parse-word 2drop ;

\ TODO
: callback (unsup) ;
: $callback (unsup) ;

: banner oem-banner? if oem-banner type else $banner then cr true to $did-banner? ;
: suppress-banner true to $did-banner? ;
