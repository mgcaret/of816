\ GoSXB board.fs
s" /" find-device
s" GoSXB" encode-string s" model" property
s" 65xSXB" encode-string s" device-type" property
s" W65C816SXB" encode-string s" compatible" property
1 encode-int s" #address-cells" property
1 encode-int s" #size-cells" property
: decode-unit 1 hex-decode-unit ;
: encode-unit 1 hex-encode-unit ;

new-device
  s" cpus" device-name
  1 encode-int s" #address-cells" property
  0 encode-int s" #size-cells" property
  : decode-unit 1 hex-decode-unit ;
  : encode-unit 1 hex-encode-unit ;
  new-device
    0 encode-int s" reg" property
    s" WDC,65C816" device-name
    s" cpu" device-type
    1 encode-int s" #address-cells" property
    0 encode-int s" #size-cells" property
    s" cpu" get-node node>path set-alias
  finish-device
  : open true ;
  : close ;
finish-device

new-device
  s" memory" 2dup device-name device-type
  0 encode-int s" reg" property
  1 encode-int s" #address-cells" property
  1 encode-int s" #size-cells" property
  : decode-unit 1 hex-decode-unit ;
  : encode-unit 1 hex-encode-unit ;
0 [IF] \ takes too much memory
  new-device
    s" ram" device-name
    0 encode-int s" reg" property
  finish-device
  new-device
    s" mmio" device-name
    1 encode-int s" #address-cells" property
    8 encode-int s" #size-cells" property
    : decode-unit 1 hex-decode-unit ;
    : encode-unit 1 hex-encode-unit ;
    7f00 encode-int s" reg" property
    new-device
      s" xcs" device-name
      7f00 encode-int s" reg" property
    finish-device
    new-device
      s" xcs" device-name
      7f20 encode-int s" reg" property
    finish-device
    new-device
      s" xcs" device-name
      7f40 encode-int s" reg" property
    finish-device
    new-device
      s" xcs" device-name
      7f60 encode-int s" reg" property
    finish-device
    new-device
      s" acia" device-name
      7f80 encode-int s" reg" property
    finish-device
    new-device
      s" pia" device-name
      7fa0 encode-int s" reg" property
    finish-device
    new-device
      s" via" device-name
      7fc0 encode-int s" reg" property
    finish-device
    new-device
      s" via" device-name
      7fe0 encode-int s" reg" property
    finish-device
  finish-device
  new-device
    s" rom" device-name
    8000 encode-int s" reg" property
  finish-device
  new-device
    s" exp" device-name
    10000 encode-int s" reg" property
  finish-device
[then]
finish-device

s" /openprom" find-device
  s" OF816,beta" encode-string s" model" property
device-end

