( ps2 keyboard ) interrupts                                    | 0 
: pinedge ( xt pin edge ) 2dup gpio_set_intr_type throw        | 1 
 drop swap 0 gpio_isr_handler_add throw ;                      | 2 
33 constant ps2clkpin 32 constant ps2datapin                   | 3 
ps2clkpin input pinmode ps2datapin input pinmode               | 4 
variable ps2data variable ps2clkcount value echo               | 5 
create ps2-key-table 128 allot                                 | 6 
: rshift-byte  2/ $7F and ;                                    | 7 
: 7lshift-byte if $80 else $00 then ;                          | 8 
: ps2shiftin 7lshift-byte ps2data @ rshift-byte or ps2data ! ; | 9 
: ps2datain? ps2clkcount @ dup 9 < swap 0 > and ;              | 10 
: ps2endframe? ps2clkcount @ 10 > ;                            | 11 
: save-key-table ( a -- ) ps2-key-table swap 128 cmove ;       | 12 
: load-key-table ( a -- ) ps2-key-table 128 cmove ;            | 13 
                                                               | 14 
                                                               | 15
                                                               
                                                               | 0 
: ps2handler ps2datain? if                                     | 1 
  ps2datapin digitalread ps2shiftin then 1 ps2clkcount +!      | 2 
ps2endframe? if                                                | 3 
  ps2data @ dup $F0 <> if                                      | 4 
echo if ps2-key-table + c@ emit then 0 ps2clkcount !           | 5 
  else drop -11 ps2clkcount !                                  | 6 
then then ;                                                    | 7 
' ps2handler ps2clkpin GPIO_INTR_POSEDGE pinedge               | 8 
: ps2key? ps2datain? 0= $F0 ps2data @ <> and ;                 | 9 
: ps2keyrel? $F0 ps2data @ = ;                                 | 10 
: ps2key begin ps2key? until ps2data @ begin ps2keyrel? until ;| 11 
: enter-key ( c -- ) dup emit space ps2key ps2-key-table + c! ;| 12 
: create-table ( c c ) 1+ swap do i enter-key loop ;           | 13 
: create-white-table cr $8 ." BACK " enter-key $9 ." TAB "     | 14 
enter-key $D ." ENTER " enter-key $20 ." SPACE " enter-key ;   | 15 

VGA.init640X400 VGA.setFont6x8                                 | 0 
0 to echo                                                      | 1 
: ps2keyc ps2key ps2-key-table + c@ ;                          | 2 
: VGA.type s>z VGA.print ;                                     | 3 
' ps2keyc is key ' VGA.type is type                            | 4 
                                                               | 5 
                                                               | 6 
                                                               | 7 
                                                               | 8 
                                                               | 9 
                                                               | 10 
                                                               | 11 
                                                               | 12 
                                                               | 13 
                                                               | 14 
                                                               | 15 

