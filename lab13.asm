;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; "Sum 1 to n Program"
; CECS 524 Spring2019 - Lab13
;
; This program reads one integer value from user,
; adds a sequence of integers from 1 to the input value,
; and print the result to the display.
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
PromNumber  db  'Enter a Number: ','$'
inputNum    dw  ?
resultSum   dw  ?
SumMsg      db  'Sum is ','$'

.CODE
Main    PROC
        MOV AX, @data
        MOV ds, AX

        sPutStr ProgTitle   ;print program title

        ;get input number
        sPutStr PromNumber
        CALL  GetDec
        MOV   inputNum, AX
        ;TODO: check if inputNum is an integer number, if not ask again.

        ;calculate sum of 1..n calling subprogram RecAdd
        ;;Sum = RecAdd(Num)
        MOV   AX, inputNum
        PUSH  AX        ;pass argument to RecAdd
        CALL  RecAdd    ;call the subprogram RecAdd
        MOV   resultSum, AX   ;move the result from RecAdd to resultSum

        ;print result
        sPutStr SumMsg
        MOV   AX, resultSum
        CALL  PutDec

        _exit   ;exit program
Main    ENDP

;[RecAdd]---------------------------------------
.DATA
PromRecAdd  db  'RecAdd:','$'
PromSubSum  db  ' Sum:','$'
n   dw ?
retSum  dw  0   ;declare and initialize retSum

.CODE
RecAdd  PROC
        push bp       ;save the current bp (stack frame)
        MOV  bp, sp   ;create new bp from sp(top)

        ;parameter to AX
        MOV   AX, word ptr [bp+4] ;4bytes up from bp is cel
        MOV   n, AX

        ;calculate the sum
        ;; if(n==1)
        ;;      return 1;
        ;;  else
        ;;      return n + recadd(n-1);

        CMP   n, 1          ; IF (n == 1)
        JNE   NumNotOne     ; ELSE goto NumNotOne
        MOV   retSum, 1     ; THEN retSum=1
        JMP    RecAddDone   ;      and goto RecAddDone
NumNotOne:                  ; ELSE { Sum = RecAdd(Num) }
        MOV   AX, n         ;
        SUB   AX, 1         ; ax = n-1
        PUSH  AX            ;pass AX as a parameter of subprogram
        CALL  RecAdd        ;call the subprogram RecAdd
        ADD   AX, n         ; ax = RecAdd(n-1) + n
        MOV   retSum, AX    ;move the result from RecAdd to Sum

RecAddDone:
        ;print msg 'RecAdd:n Sum:sum'
        sPutStr PromRecAdd  ;print msg 'RecAdd:'
        MOV   AX, n
        Call PutDec         ;print n
        sPutStr PromSubSum  ;print msg 'Sum:'
        MOV   AX, retSum
        Call PutDec         ;print sum
        _putch 13,10       ;print newline

        ;return retSum
        MOV   AX, retSum
        ;clearing up this subprogram on stack
        pop bp    ;restore the previous stack frame
        ret 2     ;2 because RecAdd() has only 1 parameter(local variable)

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
