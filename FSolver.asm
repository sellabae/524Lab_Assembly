;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; "Function Solver"
; CECS 524 Spring2019 - Spring break project
;
; This program solves
; 1) the Fibonacci number series
; 2) Ackerman's function
;
; Sella Bae
; 4/8/2019
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include Pcmac.inc
.MODEL small
.STACK 100h

.DATA
ProgTitle     db  '[CECS 524 Function Solver]',0Dh,0Ah,'$'  ;string with new newline
.CODE
Main    PROC
        MOV     AX, @data
        MOV     ds, AX

        sPutStr ProgTitle     ;print program title
        CALL    Input         ;call Input

        _exit                 ;exit program
Main    ENDP

;Input--------------------------------------------------
.DATA
;PromptMenu
;-----------------------------------------------------
; MENU     1. Fibonacci    2. Ackerman    0. Quit
;-----------------------------------------------------
PromptMenu    db  0Dh,0Ah,'-----------------------------------------------------',0Dh,0Ah,' MENU     1. Fibonacci    2. Ackerman    0. Quit',0Dh,0Ah,'-----------------------------------------------------',0Dh,0Ah,'$'
PromptInput   db  'Select menu: ','$'
menu          dw  ?

.CODE
Input   PROC
        ;subprogram prep
        push    bp            ;save the current bp (stack frame)
        MOV     bp, sp        ;create new bp from sp(top)

AskInput:
        ;get input menu
        sPutStr PromptMenu    ;print menu options
        sPutStr PromptInput   ;print input prompt
        CALL    GetDec        ;get an integer (stored in ax)
        MOV     menu, AX      ;menu = ax
        ;switch(choice)
        MOV     AX, menu
        CMP     AX, 0         ;case 0:
        JE      EndInput      ;break
        MOV     AX, menu
        CMP     AX, 1         ;case 1:
        JE      Case1
        MOV     AX, menu
        CMP     AX, 2         ;case 2:
        JE      Case2
        JMP     AskInput      ;default: (none of 0,1,2)

Case1:  ;Fibonacci
        CALL    InputFib      ;call InputFib
        JMP     AskInput      ;go to AskInput

Case2:  ;Ackerman
        CALL    InputAck      ;call InputAck
        JMP     AskInput      ;go to AskInput

EndInput:
        pop     bp            ;restore the previous stack frame
        ret                   ;return (no parameter was passed)

Input   ENDP

;InputFib----------------------------------------------
.DATA
PromptFib     db  'Fibonacci',0Dh,0Ah,'$'
PromptN       db  'Enter n: ','$'
inputN        dw  ?     ;int n for Fib(n)
fibRst        dw  ?     ;result from Fib(n)
MsgFibRst1    db  'Fib(','$'
MsgFibRst2    db  ')=','$'

.CODE
InputFib  PROC
          push bp               ;save the current bp (stack frame)
          MOV  bp, sp           ;create new bp from sp(top)

          sPutStr PromptFib     ;print "[Fibonacci]"
          ;Get user input
          sPutStr PromptN       ;print "Enter n: "
          CALL    GetDec        ;get int x
          MOV     inputN, AX
          ;Call Fib(n)
          MOV     AX, inputN
          PUSH    AX            ;pass argument n
          CALL    Fib           ;Fib(n)
          MOV     fibRst, AX    ;return value from Fib(n)
          ;Print result
          sPutStr MsgFibRst1    ;print "Fib("
          MOV     AX, inputN
          CALL    PutDec        ;print n
          sPutStr MsgFibRst2    ;print ")="
          MOV     AX, fibRst
          CALL    PutDec        ;print result
          _putch  0Dh, 0Ah      ;print new line

          ;Return
          pop     bp            ;restore the previous stack frame
          ret                   ;return (no parameter was passed)
InputFib  ENDP
;InputAck----------------------------------------------
.DATA
PromptAck     db  'Ackerman',0Dh,0Ah,'$'
PromptX       db  'Enter x: ','$'
PromptY       db  'Enter y: ','$'
inputX        dw  ?     ;int x, y for Ack(x,y)
inputY        dw  ?
ackRst        dw  ?     ;result from Ack(x,y)
MsgAckRst1    db  'Ack(','$'
MsgAckRst2    db  ')=','$'

.CODE
InputAck  PROC
          push bp               ;save the current bp (stack frame)
          MOV  bp, sp           ;create new bp from sp(top)

          sPutStr PromptAck     ;print "[Ackerman]"
          ;Get user input
          sPutStr PromptX       ;print "Enter x: "
          CALL    GetDec        ;get int x
          MOV     inputX, AX
          sPutStr PromptY       ;print "Enter y: "
          CALL    GetDec        ;get int y
          MOV     inputY, AX
          ;Call Ack(x,y)
          MOV     AX, inputX
          PUSH    AX            ;pass argument x
          MOV     AX, inputY
          PUSH    AX            ;pass argument y
          CALL    Ack           ;Ack(x,y)
          MOV     ackRst, AX    ;return value from Ack(x,y)
          ;Print result
          sPutStr MsgAckRst1  ;print "Ack("
          MOV     AX, inputX
          CALL    PutDec        ;print x
          _putch  44            ;print ","
          MOV     AX, inputY
          CALL    PutDec        ;print y
          sPutStr MsgAckRst2    ;print ")="
          MOV     AX, ackRst
          CALL    PutDec        ;print result
          _putch  13, 10        ;print new line

          ;Return
          pop     bp            ;restore the previous stack frame
          ret                   ;return (no parameter was passed)
InputAck  ENDP

;Fibonacci---------------------------------------------
.CODE
Fib     PROC
        push bp               ;save the current bp (stack frame)
        MOV  bp, sp           ;create new bp from sp(top)
        ;access parameter in stack
        ; MOV     AX, word ptr [bp+4]  ;parameter is 4 bytes up from bp
        ; MOV     n, AX         ;n = ax
        MOV     AX, word ptr [bp+4]   ;get n

        ;calculation
        ;...
        ;result in AX
        ;...
        ADD     AX, 1
ReturnFib:
        pop     bp            ;restore the previous stack frame
        ret     2             ;2 because Fib() had 1 parameter(local var)
Fib     ENDP

;Ackerman----------------------------------------------
.CODE
Ack     PROC
        push bp               ;save the current bp (stack frame)
        MOV  bp, sp           ;create new bp from sp(top)
        ;access parameters in stack
        ; MOV     AX, word ptr [bp+6]  ;first param is 6 bytes up from bp
        ; MOV     x, AX         ;x = ax
        ; MOV     AX, word ptr [bp+4]  ;second param is 4 bytes up from bp
        ; MOV     y, AX         ;y = ax
        MOV     AX, word ptr [bp+6]   ;get x
        MOV     BX, word ptr [bp+4]   ;get y

        ;calculation
        ;...
        ;result in AX
        ;...
        ADD     AX, BX
ReturnAck:
        pop     bp            ;restore the previous stack frame
        ret     4             ;4 because Ack() had 2 parameters(local var)
Ack     ENDP


;[PutDec]---------------------------------------
.DATA
M32768  db  '-32768$'
.CODE
PutDec  PROC
        push    ax
        push    bx
        push    cx
        push    dx
        cmp     ax, -32768; -32768 is a special case as there
        jne     TryNeg    ; is no representation of +32768
        _PutStr M32768
        jmp     Done
TryNeg:
        cmp     ax, 0     ; If number is negative ...
        jge     NotNeg
        mov     bx, ax    ; save from it from _PutCh
        neg     bx        ; make it positive and...
        _PutCh  '-'       ; display a '-' character
        mov     ax, bx    ; To prepare for PushDigs
NotNeg:
        mov     cx, 0     ; Initialize digit count
        mov     bx, 10    ; Base of displayed number
PushDigs:
        sub     dx, dx    ; Convert ax to unsigned double-word
        div     bx
        add     dl, '0'   ; Compute the Ascii digit...
        push    dx        ; ...push it (can push words only)...
        inc     cx        ; ...and count it
        cmp     ax, 0     ; Don't display leading zeroes
        jne     PushDigs
PopDigs:      ; Loop to display the digits
        pop     dx        ; (in reverse of the order computed)
        _PutCh  dl
        loop    PopDigs
Done:
        pop     dx        ; Restore registers
        pop     cx
        pop     bx
        pop     ax
        ret
PutDec  ENDP

;[GetDec]---------------------------------------
.DATA
  Sign    DB  ?
.CODE
GetDec  PROC
        push    bx        ; Don't need to save ax, but bx, cx, ...
        push    cx        ; ...dx must be saved and restored
        push    dx
        mov     bx, 0     ; accumulated NumberValue in bx := 0
        mov     cx, 10
        mov     Sign, '+' ; Guess that sign will be '+'
        _GetCh            ; Read character ==> al
        cmp     al, '-'   ; Is first character a minus sign?
        jne     AfterRead
        mov     Sign, '-' ; yes
ReadLoop:
        _GetCh
AfterRead:
        cmp     al, '0'   ; Is character a digit?
        jl      Done2     ; No
        cmp     al, '9'
        jg      Done2     ; No
        sub     al, '0'   ; Yes, cvt to DigitValue and extend to a
        mov     ah, 0     ; word (so we can add it to NumberValue)
        xchg    ax, bx    ; Save DigitValue
        ; and set up NumberValue for mul
        mul     cx        ; NumberValue * 10 ...
        add     ax, bx    ; + DigitValue ...
        mov     bx, ax    ; ==> NumberValue
        jmp     ReadLoop
Done2:
        cmp     al, 13    ; If last character read was a RETURN...
        jne     NoLF
        _PutCh  10        ; ...echo a matching line feed
NoLF:
        cmp     Sign, '-'
        jne     Positive
        neg     bx        ; Final result is in bx
Positive:
        mov     ax, bx    ; Returned value --> ax
        pop     dx        ; restore registers
        pop     cx
        pop     bx
        ret
GetDec  ENDP


END Main
