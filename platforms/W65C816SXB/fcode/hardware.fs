\ W65C816SXB hardware support

start1 hex

." W65C816SXB hardware support by M.G. "

external

7F80 value ACIA
7FA0 value PIA
7FC0 value VIA1
7FE0 value VIA2

struct
  0 field ACIA>RXD
  1 field ACIA>TXD
  1 field ACIA>SR
  1 field ACIA>CMD
  1 field ACIA>CTL
endstruct drop

struct
  0 field PIA>PIA
  1 field PIA>DDRA
  1 field PIA>CRA
  0 field PIA>PIB
  1 field PIA>DDRB
  1 field PIA>CRB
endstruct drop

struct
  0 field VIA>ORB
  1 field VIA>IRB
  0 field VIA>ORA
  1 field VIA>IRA
  1 field VIA>DDRB
  1 field VIA>DDRA
  2 field VIA>T1C
  2 field VIA>T1L
  2 field VIA>T2C
  1 field VIA>SR
  1 field VIA>ACR
  1 field VIA>PCR
  1 field VIA>IFR
  1 field VIA>IER
  0 field VIA>ORAN
  1 field VIA>IRAN
endstruct drop

." loaded!"

fcode-end

