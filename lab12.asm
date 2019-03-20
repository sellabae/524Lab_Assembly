;CECS 524 Spring2019 - Lab12 3/19/2019
;@author Sella Bae

include Pcmac.inc
.MODEL small
.STACK 100h

.DATA
ProgTitle   db  '[Celsius To Farenheit]','$'
PromCelsius db  'Enter celsius temperature: ','$'
ResultMsgCelsius  db  ' Celsius is ','$'
ResultMsgFahrenheit db  ' Fahrenheit. ','$'
Celsius     dw  ?
Fahrenheit  dw  ?

.CODE
Main  PROC
    MOV AX, @data
    MOV ds, AX

    ;print program title
    sPutStr ProgTitle
    _putch 13, 10

  Start:
    ;Get input for Celsius
    sPutStr PromCelsius
    CALL  GetDec
    MOV   Celsius, AX

    ;Check if input celsius is not 0
    MOV   AX, Celsius
    CMP   AX, 0     ; if(Celsius==0)
    JE    Start     ; then repeat. ask input again

    ;Call C2F subprogram
    MOV   AX, Celsius
    PUSH  AX              ;argument to C2F
    CALL  C2F             ;call subprogram
    MOV   Fahrenheit, AX  ;store the result from C2F to Fahrenheit

    ;Print the result
    MOV   AX, Celsius
    CALL PutDec                 ;Celsius
    sPutStr ResultMsgCelsius ;' Celsius is '
    MOV   AX, Fahrenheit
    CALL PutDec                 ;Fahrenheit
    sPutStr ResultMsgFahrenheit ;' Fahrenheit. '
    _putch 13, 10

    _exit   ;exit program

Main ENDP


;C2F subprogram
.DATA
Cel   dw  ?
nine  dw  9
five  dw  5
thirtytwo dw 32

.CODE
C2F PROC

    push bp       ;save the current bp (stack frame)
    MOV  bp, sp   ;create new bp from sp(top)

    ;parameter to AX
    MOV   AX, word ptr [bp+4] ;4bytes up from bp is cel

    ;calculation
    MUL   nine
    DIV   five
    ADD   AX, thirtytwo

    ;clearing up this subprogram on stack
    pop bp    ;restore the previous stack frame
    ret 2     ;2 because F2C only has 1 parameter(local var)

C2F ENDP


;[PutDec]---------------------------------------
 .DATA
M32768  db  '-32768$'
    .CODE

    PutDec  PROC
      push    ax
      push    bx
      push    cx
      push    dx
      cmp ax, -32768 ;    -32768 is a special case as there
      jne TryNeg ;      is no representation of +32768
      _PutStr M32768
      jmp Done
  TryNeg:
      cmp ax, 0 ;     If number is negative ...
      jge NotNeg
      mov bx, ax ;      save from it from _PutCh
      neg bx ;          make it positive and...
      _PutCh  '-' ;         display a '-' character
      mov ax, bx ;    To prepare for PushDigs
  NotNeg:
      mov cx, 0 ;     Initialize digit count
      mov bx, 10 ;    Base of displayed number
  PushDigs:
      sub dx, dx ;    Convert ax to unsigned double-word
      div bx
      add dl, '0' ;   Compute the Ascii digit...
      push    dx ;        ...push it (can push words only)...
      inc cx ;        ...and count it
      cmp ax, 0   ;   Don't display leading zeroes
      jne PushDigs
  ;
  PopDigs:    ;       Loop to display the digits
      pop dx ;          (in reverse of the order computed)
      _PutCh  dl
      loop    PopDigs
  Done:
      pop dx ;    Restore registers
      pop cx
      pop bx
      pop ax
      ret
  PutDec  ENDP

;[GetDec]---------------------------------------
      .DATA
  Sign    DB  ?
      .CODE

  GetDec  PROC
      push    bx ;        Don't need to save ax, but bx, cx, ...
      push    cx ;        ...dx must be saved and restored
      push    dx
      mov bx, 0 ;     accumulated NumberValue in bx := 0
      mov cx, 10
      mov Sign, '+' ; Guess that sign will be '+'
      _GetCh  ;       Read character ==> al
      cmp al, '-' ;   Is first character a minus sign?
      jne AfterRead
      mov Sign, '-' ;   yes
  ReadLoop:
      _GetCh
  AfterRead:
      cmp al, '0' ;   Is character a digit?
      jl  Done2 ;        No
      cmp al, '9'
      jg  Done2 ;        No
      sub al, '0' ;     Yes, cvt to DigitValue and extend to a
      mov ah, 0 ;        word (so we can add it to NumberValue)
      xchg    ax, bx ;    Save DigitValue
          ;          and set up NumberValue for mul
      mul cx ;        NumberValue * 10 ...
      add ax, bx ;      + DigitValue ...
      mov bx, ax ;      ==> NumberValue
      jmp ReadLoop
      Done2:
      cmp al, 13 ;    If last character read was a RETURN...
      jne NoLF
      _PutCh 10 ;     ...echo a matching line feed
  NoLF:
      cmp Sign, '-'
      jne Positive
      neg bx ;        Final result is in bx
  Positive:
      mov ax, bx ;    Returned value --> ax
      pop dx ;        restore registers
      pop cx
      pop bx
      ret
  GetDec  ENDP

END Main
