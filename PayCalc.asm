;CECS 524 Spring2019 - Lab11 3/14/2019
;@author Sella Bae

include Pcmac.inc
.model  small
.stack  100h

.data
ProgTitle   db  '[CECS 524 Pay Calculator]', 13, 10, '$' ; otherwise we need to do _PutStr 13,10 sepeRately
PromHour    db  'Enter Hours workered: ','$'
PromRate    db  'Enter Rate: ','$'
PromInsur   db  'Enter Insurance: ','$'
Hours   dw  ?
Rate    dw  ?
Insur   dw  ?   ;Insurence
Gross   dw  ?   ;Gross pay
Tax     dw  ?
TaxRate dw  12
Hundred dw  100
NetPay  dw  ?
GrossMessage  db  '[Gross pay] ','$'
TaxMessage    db  '[Tax (12%)] ','$'
InsurMessage  db  '[Insurance] ','$'
NetPayMessage db  '[ Net pay ] ','$'

.code
Main  PROC
    MOV AX, @data
    MOV ds, AX

    sPutStr ProgTitle ;print programtitle
    _putch  13, 10

    ;get inputs
    sPutStr  PromHour ;get Hours
    CALL  GetDec
    MOV   Hours, AX
    sPutStr PromRate  ;get Rate
    CALL  GetDec
    MOV   Rate, AX
    sPutStr PromInsur ;get Insururence
    CALL  GetDec
    MOV   Insur, AX

    ;Gross = Hours * Rate
    MOV   AX, Hours
    MUL   Rate
    MOV   Gross, AX

    ;Tax = Gross * TaxRate / 100
    MOV   AX, Gross
    MUL   TaxRate   ;NOTE size for multiplication. word x word = double (dx,ax)
    DIV   Hundred   ;NOTE size for dividend/divisor -> double/word = word
    MOV   Tax, AX

    ;NetPay = Gross - Tax - Insur
    MOV   AX, Gross
    SUB   AX, Tax
    SUB   AX, Insur
    MOV   NetPay, AX

    ;print results
    sPutStr GrossMessage  ;print result of gross
    MOV   AX, Gross
    CALL  PutDec
    _putch  13, 10

    sPutStr TaxMessage    ;print result of tax
    MOV   AX, Tax
    CALL  PutDec
    _putch  13, 10

    sPutStr InsurMessage  ;print insurance
    MOV   AX, Insur
    CALL  PutDec
    _putch  13, 10

    sPutStr NetPayMessage ;print result of netpay
    MOV   AX, NetPay
    CALL  PutDec
    _putch  13, 10

    _exit ;exit program
  Main  ENDP

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
