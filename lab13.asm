;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; "Sum 1 to n Program"
; CECS 524 Spring2019 - Lab13
;
; This program reads one integer value from user,
; adds a sequence of integers from 1 to the input value,
; and prints the result to the display.
;
; Sella Bae
; 3/29/2019
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include Pcmac.inc
.MODEL small
.STACK 100h

;[Main]-----------------------------------------
.DATA
ProgTitle   db  '[Sum 1 to n Program]',0Dh,0Ah,'$'  ;string with new line
PromNumber  db  'Enter n: $'
SumMsg      db  'Sum is $'

.CODE
Main    PROC
        MOV AX, @data
        MOV ds, AX

        sPutStr ProgTitle   ;print program title
        ;get input number
        sPutStr PromNumber  ;print "Enter a number: "
        CALL  GetDec        ;get int n
        ;call RecAdd(n)
        PUSH  AX            ;pass argument
        CALL  RecAdd        ;call RecAdd(ax)
        ;print result
        sPutStr SumMsg      ;print "Sum is "
        CALL  PutDec        ;print the result of RecAdd stored in AX

        _exit   ;exit program
Main    ENDP

;[RecAdd]---------------------------------------
;RecAdd calculates sum of 1..n by recursive calls
.CODE
RecAdd  PROC
;calculate the sum
; if(n==1)
;      return 1;
; else
;      return n + recadd(n-1);
        push bp       ;save the current bp (stack frame)
        mov  bp, sp   ;create new bp from sp(top)
        ;get parameter stored in stack 4 bytes up from bp
        MOV   AX, word ptr [bp+4] ;get param
        ;IF
        CMP   AX, 1               ;if (n <= 1)
        ;THEN
        JL    DoneRecAdd          ;go to done
        ;ELSE
        SUB   AX, 1               ;ELSE n-1
        PUSH  AX                  ;pass param
        CALL  RecAdd              ;RecAdd(n-1)
DoneRecAdd:
        ADD   AX, word ptr [bp+4] ; ax = RecAdd(n-1) + n
        pop bp    ;restore the previous stack frame
        ret 2     ;2 because RecAdd() had only 1 parameter(local variable)
RecAdd  ENDP



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
