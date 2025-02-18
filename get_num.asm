.model tiny
.code
.186
org 100h

Start:  call    GetArguments

        mov ax, 4c00h
        int 21h



;------------------------------------------------
; Get decimal number from command line arguments
; Entry:    DS:SI - addr of argument in command line
;           ZF    = 0
; Exit:     BX    - received argument (hexadecimal number)
; Destr:    AX SI 
;------------------------------------------------
GetNum          proc

                xor     ax, ax          ; null ax, because we will use al
                xor     bx, bx          ; null bx, because in bx will be senior ranks of number

NextChar:       lodsb                   ; get char
                cmp     al, 20h         ; cmp with space symbol
                je      EndNum          ; jump to end of getting number if it is space symbol

                sub     al, 30h         ; make al from char to digit
                push    ax              ; save digit (it is junior rank of number)
                mov     ax, bx      
                xor     bx, bx          ; null bx because we will use bl 
                mov     bl, 10      
                mul     bl              ; ax = al * 10
                mov     bx, ax          ; new_bx = old_bx (senior ranks of number) * 10
                pop     ax              ; get dig
                add     bx, ax          ; new_bx = old_bx * 10 + new_digit (junior rank of number)

                jmp     NextChar        ; get new char

EndNum:         ret
                endp



;------------------------------------------------
; Get color from command line arguments
; Entry:    DS:SI - addr of argument in command line
;           ZF    = 0
; Exit:     AL    - color (hexadecimal number)
; Destr:    AL SI 
;------------------------------------------------
GetColor        proc
        
                xor     ax, ax          ; null ax, because we will use al
                xor     bx, bx          ; null bx, because we will use bl 

                lodsb                   ; get first char
                cmp     al, 40h         ; cmp with 40h for find if it digit or alpha
                jb      FirstDig            

                sub     al, 07h         ; sub for alpha, skip line if digit
FirstDig:       sub     al, 30h         ; sub for digit and alpha

                mov     bl, 10h             
                mul     bl              ; ax = al * 16
                mov     bx, ax              

                lodsb                   ; get second char
                cmp     al, 40h         ; cmp with 40h for find if it digit or alpha
                jb      SecondDig                

                sub     al, 07h         ; sub for alpha, skip line if digit
SecondDig:      sub     al, 30h         ; sub for digit and alpha

                add     bx, ax          ; add next symbol value
                mov     ah, bl          ; ah - color

                inc si                  ; skip space symbol

                ret
                endp



;------------------------------------------------
; Get necessary arguments for constructing a frame from command line
; Entry:    None
; Exit:     CX      - length
;           BP      - hight
;           AH      - color
;           DX (DL) - style
;           DS:SI   - addr of the line to be output
;           DS:DI   - addr of frame style (if style = 0)
; Destr:    AL
;------------------------------------------------
GetArguments    proc
                
                mov     si, 80h + 2h    ; going to the command line and skip amount of arguments

                call    GetNum          ; get length
                mov     cx, bx          ; cx - length

                call    GetNum          ; get hight
                mov     bp, bx          ; bp - hight

                call    GetColor        ; ah - color

                push ax                 ; save color (ah)
                call    GetNum          ; get style
                mov     dx, bx          ; dx (dl) - style
                pop ax                  ; return color

                mov di, si
                cmp     dl, 0h          ; --| if style == 0, new_di = old_di + 10 (9 byte for frame style and skip space symbol)
                jne     EndGetArg       ;   | if style != 0, new_di = old_di
                add     si, 0ah         ; --| new_di - address of the line to be output

EndGetArg:      ret
                endp



end Start