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
ProgTitle     db  '[CECS 524 Function Solver by Sella Bae]',13,10,'$'  ;string with new newline
newline       db  13,10,'$'
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
;-----------------------------------------------------
; MENU     1. Fibonacci    2. Ackerman    0. Quit
;-----------------------------------------------------
PromptMenu    db  13,10,'-----------------------------------------------------',13,10,' MENU     1. Fibonacci    2. Ackerman    0. Quit',13,10,'-----------------------------------------------------',13,10,'$'
PromptInput   db  'Select menu: $'
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
        MOV     BX, AX      ;menu = ax
        ;switch(choice)
        CMP     BX, 0         ;case 0:
        JE      EndInput      ;break
        CMP     BX, 1         ;case 1:
        JE      Case1
        CMP     BX, 2         ;case 2:
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
PromptFib  db  'Fibonacci',13,10,'$'
PromptN    db  'Enter n: $'
MsgFib1    db  'Fib($'
MsgFib2    db  ')=$'
.CODE
InputFib  PROC
          push bp               ;save the current bp (stack frame)
          MOV  bp, sp           ;create new bp from sp(top)
;Print selected function
          sPutStr PromptFib     ;print "Fibonacci"
;Get user input
          sPutStr PromptN       ;print "Enter n: "
          CALL    GetDec        ;get int n
          MOV     BX, AX        ;move n to bx
;Call Fib(n)
          PUSH    BX            ;argument n
          CALL    Fib           ;Fib(n)
          MOV     CX, AX        ;move result to cx
;Print result
          sPutStr MsgFib1       ;print "Fib("
          MOV     AX, BX        ;move n to ax
          CALL    PutDec        ;print n
          sPutStr MsgFib2       ;print ")="
          MOV     AX, CX        ;move result to ax
          CALL    PutDec        ;print result
          sPutStr newline       ;print new line
;Return
          pop     bp            ;restore the previous stack frame
          ret                   ;return (no parameter was passed)
InputFib  ENDP

;InputAck----------------------------------------------
.DATA
PromptAck   db  'Ackerman',13,10,'$'
PromptX     db  'Enter x: $'
PromptY     db  'Enter y: $'
MsgAck1     db  'Ack($'
MsgAck2     db  ',$'
MsgAck3     db  ')=$'
.CODE
InputAck  PROC
          push bp               ;save the current bp (stack frame)
          MOV  bp, sp           ;create new bp from sp(top)
;Print selected function
          sPutStr PromptAck     ;print "Ackerman"
;Get user input and store in stack as local variables
          sPutStr PromptX       ;print "Enter x: "
          CALL    GetDec        ;get input x
          MOV     BX, AX        ;move x to bx
          PUSH    BX            ;store x in stack
          sPutStr PromptY       ;print "Enter y: "
          CALL    GetDec        ;get input y
          MOV     CX, AX        ;move y to cx
          PUSH    CX            ;store y in stack
;Call Fib(n)
          PUSH    BX            ;argument x
          PUSH    CX            ;argument y
          CALL    Ack           ;call Ack(x,y)
          MOV     DX, AX        ;move result to dx
;Get local variables back
          POP     CX            ;get local y from stack
          POP     BX            ;get local x from stack
;Print result
          sPutStr newline
          sPutStr MsgAck1       ;print "Ack("
          MOV     AX, BX        ;move x to ax
          CALL    PutDec        ;print x
          sPutStr MsgAck2       ;print ","
          MOV     AX, CX        ;move y to ax
          CALL    PutDec        ;print y
          sPutStr MsgAck3       ;print ")="
          MOV     AX, DX        ;move result to ax
          CALL    PutDec        ;print result in ax
;Return
          pop     bp            ;restore the previous stack frame
          ret                   ;return (no parameter was passed)
InputAck  ENDP

;Fibonacci---------------------------------------------
;f(n) = f(n-1) + f(n-2), where f(1)=1, f(2)=1
.CODE
Fib     PROC
        push bp               ;save the current bp (stack frame)
        MOV  bp, sp           ;create new bp from sp(top)
        ;access parameter in stack
        MOV     AX, word ptr [bp+4]   ;get n

; -------------------------
; if( n <= 1 )
;   return n
; else
;   return Fib(n-1) + Fib(n-2)
; -------------------------
        CMP     AX, 1         ;if(n<=1)
        JG      RecurFib      ;no, recursive case
        JMP     DoneFib       ;yes, base case. Fib(n)=n, where n=1,0

RecurFib:
        PUSH    AX            ;store n in stack

        SUB     AX, 1         ;n-1
        PUSH    AX            ;argument n-1
        CALL    Fib           ;call Fib(n-1)
        MOV     CX, AX        ;Fib(n-1) result in cx
        POP     AX            ;pop n
        PUSH    CX            ;store Fib(n-1) in stack

        SUB     AX, 2         ;n-2
        PUSH    AX            ;argument n-2
        CALL    Fib           ;call Fib(n-2)
        MOV     CX, AX        ;Fib(n-2) result in cx
        POP     AX            ;get Fib(n-1) back from stack to ax
        ADD     AX, CX        ;Fib(n-1) + Fib(n-2)
DoneFib:
        pop     bp            ;restore the previous stack frame
        ret     2             ;2 because Fib() had 1 parameter(local var)
Fib     ENDP

;Ackerman----------------------------------------------
;A(0,j) = j+1               for j>=0
;A(i,0) = A(i-1, 1)         for i>0
;A(i,j) = A(i-1, A(i,j-1))  for i,j>0
.CODE
Ack     PROC
;int Ack(int x, int y)
        push    bp             ;save the current bp (stack frame)
        MOV     bp, sp         ;create new bp from sp(top)
        MOV     BX, word ptr [bp+6]   ;get x in bx
        MOV     CX, word ptr [bp+4]   ;get y in cx
        ;MOV     AX, 0          ;Initialize ax = 0
; ------------------------------------------------(i=x,j=y)
; if (i == 0)
;    return j++                  //base case  when i=0
; else if (j == 0)
;    return Ack(i-1, 1)          //recursive1 when i>0,j=0
; else
;    return Ack(i-1, Ack(i,j-1)) //recursive2 when i>0,j>0
; ---------------------------------------------------------
        CMP     BX, 0         ;if (i == 0)
        JE      BaseAck       ;yes, base case        when i=0
        JL      DoneAck       ;i<0 get out
        CMP     CX, 0         ;else if (j == 0)
        JE      RecurAck1     ;yes, recursive case1  when i>0,j=0
        JMP     RecurAck2     ;no, recursive case2   when i>0,j>0
BaseAck:
;when i=0 in bx, j>0 in cx    ;
;debugging
PUSH    BX            ;arg i
PUSH    CX            ;arg j
CALL    PrintAck      ;print "A(i,j)"
;basecase work
        MOV     AX, 1         ;j+1
        ADD     AX, CX        ;
        ;msg for debugging
        ; sPutCh  'b',':',' '
        ; CALL    PutDec
        ; sPutStr newline
        ;end msg
        JMP     DoneAck

RecurAck1:
;when i>0 in bx, j=0 in cx    ;yes, Ack(i-1,1)
;debugging
PUSH    BX            ;arg i
PUSH    CX            ;arg j
CALL    PrintAck      ;print "A(i,j)"
;recursive work
        MOV     AX, BX        ;i-1
        SUB     AX, 1
        PUSH    AX            ;argument i-1
        MOV     AX, 1         ;1
        PUSH    AX            ;argument 1
        CALL    Ack           ;call Ack(i-1,1)
        ;msg for debugging
        ; sPutCh  '1',':',' '
        ; CALL    PutDec
        ; sPutStr newline
        ;end msg
        JMP     DoneAck

RecurAck2:
;when i>0 in bx, j>0 in cx    ;Ack(i-1, Ack(i,j-1))
;debugging
PUSH    BX            ;arg i
PUSH    CX            ;arg j
CALL    PrintAck      ;print "A(i,j)"
;recursive work
        PUSH    BX            ;argument i
        MOV     AX, CX        ;j-1
        SUB     AX, 1
        PUSH    AX            ;argument j-1
        CALL    Ack           ;Ack(i,j-1)
        ;msg for debugging
        ; sPutCh  '2',':',':',' '
        ; CALL    PutDec
        ; sPutStr newline
        ;end msg
        MOV     DX, AX        ;store Ack(i,j-1) in dx
        MOV     AX, BX        ;i-1
        SUB     AX, 1
        PUSH    AX            ;argument i-1
        PUSH    DX            ;argument Ack(i,j-1)
        CALL    Ack           ;call Ack(i-1, Ack(i,j-1))
        ;msg for debugging
        ; sPutCh  '2',':',' '
        ; CALL    PutDec
        ; sPutStr newline
        ;end msg
        JMP     DoneAck

DoneAck:
        ;return back to caller
        pop     bp            ;restore the previous stack frame
        ret     4             ;4 because Ack() had 2 parameters(local var)
Ack     ENDP

;[PrintAck] for debugging-------------------------
.CODE
PrintAck  PROC
;int Print(int i, int j)
          push    bp        ;save the current bp (stack frame)
          MOV     bp, sp    ;create new bp from sp(top)
          ;print A(i,j)=result
          sPutCh  ' ','A','('                ;print "A("
          MOV     AX, word ptr [bp+6]   ;get i
          CALL    PutDec                ;print i
          sPutCh  ','                   ;print ","
          MOV     AX, word ptr [bp+4]   ;get j
          CALL    PutDec                ;print j
          sPutCh  ')'               ;print ")"
          ;return
          pop     bp       ;restore the previous stack frame
          ret     4        ;2*2=4 because 2 params were in stack
PrintAck  ENDP

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
