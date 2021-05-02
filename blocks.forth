( ps2 keyboard ) interrupts                                    |0
: pinedge ( xt pin edge ) 2dup gpio_set_intr_type throw        |1
 drop swap 0 gpio_isr_handler_add throw ;                      |2
33 constant ps2clkpin 32 constant ps2datapin                   |3
ps2clkpin input pinmode ps2datapin input pinmode               |4
variable ps2data variable ps2clkcount                          |5
create ps2-key-table 256 allot value ps2-shift-key value shift |6
value ps2rel? value ps2key? : ps2in ps2datapin digitalread ;   |7
: lookup ps2-key-table + shift + c@ ;                          |8
: rshb 2/ $7F and ; : 7lshb if $80 else $00 then ;             |9
: ps2datain? ps2clkcount @ dup 9 < swap 0 > and ;              |10
: ps2endframe? ps2clkcount @ 10 > ;                            |11
: ps2shiftin ps2in 7lshb ps2data @ rshb or ps2data ! ;         |12
: save-key-table ( a -- ) ps2-key-table swap 256 cmove ;       |13
: load-key-table ( a -- ) ps2-key-table 256 cmove ;            |14
: clear-key-table ( -- ) 256 0 do 0 ps2-key-table c! ;         |15
                                                               
: kshift ps2-shift-key = if ps2rel? 0= 128 and to shift then ; |0
: print? dup $F0 <> swap ps2-shift-key <> and ;                |1
: decode dup kshift dup print? ps2rel? 0= and to ps2key?       |2
$F0 = to ps2rel? ;                                             |3
: ps2handler ps2datain? if ps2shiftin then 1 ps2clkcount +!    |4
ps2endframe? if ps2data @ decode 0 ps2clkcount ! then ;        |5
' ps2handler ps2clkpin GPIO_INTR_POSEDGE pinedge               |6
: key! ps2-key-table + shift + c! ;                            |7
: ps2key begin ps2key? until ps2data @ begin ps2key? 0= until ;|8
: enter-key ( c -- ) dup emit space ps2key key! ;              |9
: create-table ( c c ) 1+ swap do i enter-key loop ;           |10
: create-white-table cr $8 ." BACK " enter-key $9 ." TAB "     |11
enter-key $A ." ENTER " enter-key $20 ." SPACE " enter-key ;   |12
: echo begin ps2key dup lookup emit 118 ( esc ) = until ;      |13
0 to shift -1 to ps2rel? 0 to ps2key?                          |14
$12 to ps2-shift-key                                           |15

VGA.init400x300 VGA.setFont6x8                                 |0
: ps2keyc ps2key lookup ;                                      |1
: VGA.type s>z VGA.print ;                                     |2
' ps2keyc is key ' VGA.type is type                            |3
                                                               |4
                                                               |5
                                                               |6
                                                               |7
                                                               |8
                                                               |9
                                                               |10
                                                               |11
                                                               |12
                                                               |13
                                                               |14
                                                               |15

