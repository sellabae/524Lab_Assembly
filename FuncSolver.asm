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

        sPutStr ProgTitle   ;print program title
        CALL    Input         ;call Input

        _exit               ;exit program
Main    ENDP

;Input--------------------------------------------------
.DATA
PromptChoice  db  '1. Fibonacci',0Dh,0Ah,'2. Ackerman',0Dh,0Ah,'0. Quit',0Dh,0Ah,'$'
PromptInput   db  'Enter choice: ','$'
PromptFib     db  '[Fibonacci]',0Dh,0Ah,'$'
PromptAck     db  '[Ackerman]',0Dh,0Ah,'$'
choice        dw  ?
.CODE
Input   PROC
        ;get input choice
        sPutStr PromptChoice  ;print choice options
        sPutStr PromptInput   ;print input choice
        CALL    GetDec        ;get a integer and store in ax
        MOV     choice, AX    ;choice = ax

        ;switch(choice)
        ;MOV     AX, choice
        CMP     choice, 0         ;case 0:
        JE      EndInput
        CMP     choice, 1         ;case 1:
        JE      IfOne
        CMP     choice, 2         ;case 2:
        JE      IfTwo
        JMP     EndInput

IfOne:  ;Fibonacci
        sPutStr PromptFib
        ;..
        JMP     EndInput      ;break

IfTwo:  ;Ackerman
        sPutStr PromptAck
        ;..
        JMP     EndInput      ;break

EndInput:
        ;clearing up this subprogram on stack
        pop bp    ;restore the previous stack frame
        ret 6     ;2 because F2C only has 1 parameter(local var)

Input   ENDP

;Fibonacci---------------------------------------------
.CODE
Fib     PROC
        ;...
Fib     ENDP

;Ackerman----------------------------------------------
.CODE
Ack     PROC
        ;...
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
