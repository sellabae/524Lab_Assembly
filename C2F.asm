;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; "Celsius to Fahrenheit Program"
; CECS 524 Spring2019 - Lab12. Subprogram
;
; This program reads a celsius temperature from user,
; calculates it to fahrenheit temperature,
; and prints it to display.
;
; Sella Bae
; 3/19/2019
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include Pcmac.inc
.MODEL small
.STACK 100h

.DATA
ProgTitle   db  '[Celsius To Farenheit]',13,10,'$'
PromptCel   db  'Enter celsius temperature: $'
MsgCel      db  ' Celsius is $'
MsgFah      db  ' Fahrenheit.$'

.CODE
Main  PROC
      MOV     AX, @data
      MOV     ds, AX
;print program title
      sPutStr ProgTitle

EnterCel:
;Get input cel
      sPutStr PromptCel   ;print "Enter..."
      CALL    GetDec      ;get input cel
      MOV     BX, AX      ;move input to bx

;Check if input cel is greater than 0
      CMP     BX, 0       ;if (c >= 0)
                          ;compared result in ax
      JL      EnterCel    ;no, then ask input again
      PUSH    BX          ;store cel in stack frame for main()
;Call C2F(cel) subprogram
      PUSH    BX          ;argument cel to C2F
      CALL    C2F         ;call subprogram C2F(cel)
      MOV     CX, AX      ;move return value from C2F() to cx

;Print the result
      POP     AX          ;get local variable cel back from stack
      CALL    PutDec      ;print celsius
      sPutStr MsgCel      ;print " Celsius is "
      MOV     AX, CX      ;move fahrenheit to ax
      CALL    PutDec      ;print fahrenheit
      sPutStr MsgFah      ;print " Fahrenheit."
      sPutCh  13, 10      ;print newline

      _exit               ;exit program

Main ENDP


;C2F subprogram
.CODE
C2F   PROC
;------------------------------
; int C2F(int cel){
;   return (cel * 9 / 5) + 32
; }
;------------------------------
      push  bp          ;save the current bp (stack frame)
      mov   bp, sp      ;create new bp from sp(top)
;parameter to AX
      MOV   AX, word ptr [bp+4] ;4bytes up from bp is cel(local variable)

;calculation
      MOV   BX, 9       ;move 9 to bx
      MUL   BX          ;ax = ax * 9
      MOV   BX, 5       ;move 5 to bx
      DIV   BX          ;ax = ax / 5
      MOV   BX, 32      ;move 32 to bx
      ADD   AX, BX      ;ax = ax + 32

;clearing up this subprogram on stack
      pop   bp          ;restore the previous stack frame
      ret   2           ;2 because C2F only has 1 parameter(local var)
C2F   ENDP


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
