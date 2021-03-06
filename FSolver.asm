;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; "Function Solver"
; CECS 524 Spring2019 - Spring break project
;
; This program solves:
; 1) Fibonacci sequence
; 2) Ackerman's function
;
; C++ sketch of this program:
; int Fib(int n);
; int Ack(int x, int y);
; void InputFib(); //ask input, call Fib(), display result
; void InputAck(); //ask input, call Ack(), display result
; void Menu();     //ask menu, call InputFib() or InputAck()
; void main();     //call Menu()
;
; Sella Bae
; 4/9/2019
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include Pcmac.inc
.MODEL small
.STACK 100h

.DATA
ProgTitle  db  '[CECS 524 Function Solver by Sella Bae]',13,10,'$'
newline    db  13,10,'$'
MsgNegN    db  'Enter zero or positive.',13,10,'$'
.CODE
Main    PROC
        MOV     AX, @data
        MOV     ds, AX

        sPutStr ProgTitle     ;print program title
        CALL    Menu          ;call Menu

        _exit                 ;exit program
Main    ENDP


;Menu--------------------------------------------------------------
;Purpose: Procedure Menu asks one input from user,
;         calls InputFib or InputAck depend on the input.
;Parameters: none
;Input: one number
;Display:
;-----------------------------------------------------
; MENU     1. Fibonacci    2. Ackerman    0. Quit
;-----------------------------------------------------
.DATA
PromptMenu    db  13,10,'-----------------------------------------------------',13,10,' MENU     1. Fibonacci    2. Ackerman    0. Quit',13,10,'-----------------------------------------------------',13,10,'$'
PromptSelect  db  'Select menu: $'
.CODE
Menu    PROC
        ;subprogram prep
        push    bp            ;save the current bp (stack frame)
        mov     bp, sp        ;create new bp from sp(top)
AskInput:
;Get menu input
        sPutStr PromptMenu    ;print menu options
        sPutStr PromptSelect  ;print input prompt
        CALL    GetDec        ;get menu input
        MOV     BX, AX        ;move choice to bx
;switch(choice)
        CMP     BX, 0         ;case 0:
        JE      Menu0
        CMP     BX, 1         ;case 1:
        JE      Menu1
        CMP     BX, 2         ;case 2:
        JE      Menu2
        JMP     AskInput      ;default: (none of 0,1,2)
Menu1:  ;Fibonacci
        CALL    InputFib      ;call InputFib
        JMP     AskInput      ;go to AskInput
Menu2:  ;Ackerman
        CALL    InputAck      ;call InputAck
        JMP     AskInput      ;go to AskInput
Menu0:  ;Exit
        pop     bp            ;restore the previous stack frame
        ret                   ;return (no parameter was passed)
Menu    ENDP


;InputFib--------------------------------------------------------------
;Purpose: Procedure InputFib asks one input from user,
;         calls Fib, and prints output
;Parameters: none
;Input: one natural number
;Output: print "Fib(n)=result"
.DATA
PromptFib  db  'Fibonacci',13,10,'$'
PromptN    db  'Enter n: $'
MsgFib1    db  'Fib($'
MsgFib2    db  ')=$'
.CODE
InputFib  PROC
          push bp               ;save the current bp (stack frame)
          mov  bp, sp           ;create new bp from sp(top)
;Print selected function
          sPutStr PromptFib     ;print "Fibonacci"
;Get user input and store in stack as local variable
EnterN:
          sPutStr PromptN       ;print "Enter n: "
          CALL    GetDec        ;get input n
          MOV     BX, AX        ;move n to bx
          CMP     BX, 0         ;if (n < 0)
          JGE     ContInputFib  ;n>=0, continue InputFib
          sPutStr MsgNegN       ;n<0,  print "Enter zero or positive."
          JMP     EnterN        ;ask input again
ContInputFib:
          PUSH    BX            ;store n in stack
;Call Fib(n)
          PUSH    BX            ;argument n
          CALL    Fib           ;Fib(n)
          MOV     CX, AX        ;move result to cx
;Print result
          sPutStr MsgFib1       ;print "Fib("
          POP     AX            ;get input n back from stack to ax
          CALL    PutDec        ;print n
          sPutStr MsgFib2       ;print ")="
          MOV     AX, CX        ;move result to ax
          CALL    PutDec        ;print result
          sPutStr newline       ;print new line
;Return
          pop     bp            ;restore the previous stack frame
          ret                   ;return (no parameter was passed)
InputFib  ENDP


;InputAck--------------------------------------------------------------
;Purpose: Procedure InputAck asks two inputs from user,
;         calls Ack, and prints output
;Parameters: none
;Input: two natural numbers
;Output: print "Ack(x,y)=result"
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
          mov  bp, sp           ;create new bp from sp(top)
;Print selected function
          sPutStr PromptAck     ;print "Ackerman"
;Get user input and store in stack as local variables
EnterX:
          sPutStr PromptX       ;print "Enter x: "
          CALL    GetDec        ;get input x
          MOV     BX, AX        ;move x to bx
          CMP     BX, 0         ;if(x<0)
          JGE     EnterY        ;x>=0, continue to ask another input
          sPutStr MsgNegN       ;x<0,  print "Enter zero or positive."
          JL      EnterX        ;ask input x again
EnterY:
          sPutStr PromptY       ;print "Enter y: "
          CALL    GetDec        ;get input y
          MOV     CX, AX        ;move y to cx
          CMP     CX, 0         ;if(y<0)
          JGE     ContInputAck  ;y>=0, continue InputAck
          sPutStr MsgNegN       ;y<0,  print "Enter zero or positive."
          JL      EnterY        ;ask input y again
ContInputAck:
          PUSH    BX            ;store x in stack
          PUSH    CX            ;store y in stack
;Call Fib(n)
          PUSH    BX            ;argument x
          PUSH    CX            ;argument y
          CALL    Ack           ;call Ack(x,y)
          MOV     DX, AX        ;move result to dx
;Get local variables back
          POP     CX            ;get input y from stack to cx
          POP     BX            ;get input x from stack to bx
;Print result
          sPutStr MsgAck1       ;print "Ack("
          MOV     AX, BX        ;move x to ax
          CALL    PutDec        ;print x
          sPutStr MsgAck2       ;print ","
          MOV     AX, CX        ;move y to ax
          CALL    PutDec        ;print y
          sPutStr MsgAck3       ;print ")="
          MOV     AX, DX        ;move result to ax
          CALL    PutDec        ;print result
          sPutStr newline       ;print new line
;Return
          pop     bp            ;restore the previous stack frame
          ret                   ;return (no parameter was passed)
InputAck  ENDP



.CODE
;Fib-------------------------------------------------------------------
;Purpose: Function Fib calculates Fibonacci number
;Parameters: one natural number pushed into stack from caller
;Returns: AX
;Fibonacci Logic:
;  f(n) = f(n-1) + f(n-2), where f(1)=1, f(2)=1
;Code Sketch:
;-------------------------------------------------------------
; int Fib(int n) {
;    if( n <= 1 )   return n              //base case
;    else   return Fib(n-1) + Fib(n-2)    //recursive
; } //let's change this to a better Fib() algorithm later!
;-------------------------------------------------------------
Fib     PROC
        push    bp            ;save the current bp (stack frame)
        mov     bp, sp        ;create new bp from sp(top)
        MOV     BX, word ptr [bp+4]   ;get param n in stack into bx
        MOV     AX, 0         ;initialize ax = 0
;Branching
        CMP     BX, 0         ;if(n < 0)
        JL      DoneFib       ;n<0,   return 0(in ax)
        CMP     BX, 1         ;if (n <= 1)
        JG      RecurFib      ;n>1,   recursive
        MOV     AX, BX        ;n=1,0, return n
        JMP     DoneFib       ;

RecurFib:
        PUSH    BX            ;store n in stack
;Fib(n-1)
        SUB     BX, 1         ;n-1 (bx=bx-1)
        PUSH    BX            ;argument n-1
        CALL    Fib           ;call Fib(n-1)
        MOV     CX, AX        ;move result to cx
        POP     BX            ;get n back from stack to bx
        PUSH    CX            ;store Fib(n-1) in stack
;Fib(n-2)
        SUB     BX, 2         ;n-2 (bx=bx-2)
        PUSH    BX            ;argument n-2
        CALL    Fib           ;call Fib(n-2)
        MOV     CX, AX        ;move result to cx
;Fib(n-1)+Fib(n-2)
        POP     AX            ;get Fib(n-1) back from stack to ax
        ADD     AX, CX        ;result = Fib(n-1) + Fib(n-2)

DoneFib:
;Return back to caller
        pop     bp            ;restore the previous stack frame
        ret     2             ;2 because Fib() had 1 parameter(local var)

Fib     ENDP


.CODE
;Ack-------------------------------------------------------------------
;Purpose: Function Ack calculates Ackermann's function from two inputs
;Parameters: two natural numbers pushed into stack from caller
;Returns: AX
;Ackerman Logic:
;  A(0,j) = j+1               for i=0,j>0
;  A(i,0) = A(i-1, 1)         for i>0,j=0
;  A(i,j) = A(i-1, A(i,j-1))  for i>0,j>0
;Code Sketch:
;-------------------------------------------------------------
; int Ack(int i, int j) {           //assume i,j>=0
;    if (i == 0)
;       return j++                  //base case  when i=0
;    else if (j == 0)
;       return Ack(i-1, 1)          //recursive1 when i>0,j=0
;    else
;       return Ack(i-1, Ack(i,j-1)) //recursive2 when i>0,j>0
; }
;-------------------------------------------------------------
Ack     PROC
        push    bp            ;save the current bp (stack frame)
        mov     bp, sp        ;create new bp from sp(top)
        MOV     BX, word ptr [bp+6]   ;get param x in stack into bx
        MOV     CX, word ptr [bp+4]   ;get param y in stack into cx
        MOV     AX, 0         ;initialize ax = 0
;Branching
        CMP     BX, 0         ;if (i == 0)
        JL      DoneAck       ;i<0, return 0
        JE      IZero         ;i=0, base case        when i=0
        CMP     CX, 0         ;i>0, if (j == 0)
        JL      DoneAck       ;     j<0, return 0
        JE      JZero         ;     j=0, recursive1  when i>0,j=0
        JMP     IJGreater     ;     j>0, recursive2  when i>0,j>0

IZero:
;Basecase work,   when i=0 in bx, j>0 in cx    then j++
        ADD     CX, 1         ;j+1
        MOV     AX, CX        ;move j+1 to ax
        JMP     DoneAck       ;

JZero:
;Recursive work,  when i>0 in bx, j=0 in cx    then Ack(i-1,1)
        SUB     BX, 1         ;i-1
        PUSH    BX            ;argument i-1
        MOV     CX, 1         ;1
        PUSH    CX            ;argument 1
        CALL    Ack           ;call Ack(i-1,1)
        JMP     DoneAck       ;

IJGreater:
;Recursive work,  when i>0 in bx, j>0 in cx    then Ack(i-1, Ack(i,j-1))
        PUSH    BX            ;store i in stack
;Ack(i,j-1)
        SUB     CX, 1         ;j-1
        PUSH    BX            ;argument i
        PUSH    CX            ;argument j-1
        CALL    Ack           ;Ack(i,j-1)
;Ack(i-1, Ack(i,j-1))
        POP     BX            ;get i back from stack to bx
        SUB     BX, 1         ;i-1
        PUSH    BX            ;argument i-1
        PUSH    AX            ;argument Ack(i,j-1)
        CALL    Ack           ;call Ack(i-1, Ack(i,j-1))
        JMP     DoneAck       ;

DoneAck:
;Return back to caller
        pop     bp            ;restore the previous stack frame
        ret     4             ;4 because Ack() had 2 parameters(local var)

Ack     ENDP

.CODE
;PrintAck----------------------------------------------------------
;Purpose: Procedure PrintAck prints "A(i,j)" for debugging Ackerman
;Parameters: two natural numbers pushed into stack from caller
;Returns: none
;Use:
;; PUSH    BX            ;arg i
;; PUSH    CX            ;arg j
;; CALL    PrintAck      ;print "A(i,j)"
PrintAck  PROC
          push    bp        ;save the current bp (stack frame)
          mov     bp, sp    ;create new bp from sp(top)
;Print " A(i,j)"
          sPutCh  ' ','A','('           ;print "A("
          MOV     AX, word ptr [bp+6]   ;get param i from stack
          CALL    PutDec                ;print i
          sPutCh  ','                   ;print ","
          MOV     AX, word ptr [bp+4]   ;get param j from stack
          CALL    PutDec                ;print j
          sPutCh  ')'                   ;print ")"
;Return
          pop     bp       ;restore the previous stack frame
          ret     4        ;4 because 2 params were in stack
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
