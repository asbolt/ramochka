.model tiny
.code
.186
org 100h

Start:          call    GetArguments

                cmp     dx, 0h          ;--| if style != 0, get style from FrameStyles
                je      StartDraw       ;  | if style == 0, skip this part

                                        ; \\TODO mov     si, offset FrameStyles 

StartDraw:      push di
                call    DrawFrame
                pop di


                mov cx, ds              ; --| go to our seg of mem (because we need to use scasb)
                mov es, cx              ; --|

                call DrawStr

                mov     ax, 4c00h
                int     21h



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
;           DS:DI   - addr of the line to be output
;           DS:SI   - addr of frame style (if style = 0)
; Destr:    AL BX
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
                add     di, 0ah         ; --| new_di - address of the line to be output

EndGetArg:      ret
                endp



;------------------------------------------------
; Draw a line in video meme
; Entry:    AH    - color attr
;           DS:SI - addr of 3-byte ASCII seg to draw a frame
;           CX    - line length
;           ES:DI - line beginning addr
;           DF = 0
; Exit:     None
; Destr:    AL SI DI
;------------------------------------------------
DrawLine        proc

                push cx                 ; save cx (we will need it the next time we will use this function)

                lodsb                   ; --| print the first symbol
                stosw                   ; --|

                lodsb                   ; --| print medium symbols
                rep stosw               ; --|

                lodsb                   ; --| print the last symbol
                stosw                   ; --|

                pop cx

                ret
                endp



;------------------------------------------------
; Draw a frame in video mem
; Entry:    CX      - length
;           BP      - hight
;           AH      - color
;           ES:DI   - line beginning addr
;           DS:SI   - addr of 9-byte ASCII seg to draw a frame
; Exit:     None
; Destr:    AL CX SI DI BX
;------------------------------------------------
DrawFrame       proc

                call PutLBF             ; put into ES:DI line beginning addr of frame

                push di                 ; save di to go to new line after DrawLine
                call DrawLine
                pop di
                add di, 80*2            ; go to new line

                push bp

NextLine:       push di                 ; save di to go to new line after DrawLine
                call DrawLine
                pop di
                add di, 80*2            ; go to new line
                sub si, 3h              ; go back to 3 byte in seg with frame style, because we need to print equal line then
                dec bp                  ; decrement remaining lines counter
                cmp bp, 0h              ; if remaining lines counter != 0, print another line
                jne NextLine

                pop bp

                add si, 3h              ; add 3 byte in seg with frame style, because in cycle took away the excess in the last pass
                push di                 ; save di to go to new line after DrawLine
                call DrawLine
                pop di
                add di, 80*2            ; go to new line

                ret
                endp




;------------------------------------------------
; Put into ES:DI line beginning addr of frame
; Entry:    CX      - frame length 
;           BP      - frame hight
; Exit:     ES:DI   - line beginning addr
; Destr:    AX
;------------------------------------------------
PutLBF          proc

                push    ax              ; save ax
                mov     bx, 2           ; value for mul and div

                mov     di, 0b800h      ; --| go into video mem
                mov     es, di          ; --|

                mov     ax, 80          ; --| calculate how many columns need to be indented
                sub     ax, cx          ;   |
                sub     ax, 2           ;   |
                div     bx              ;   |
                mul     bx              ; --|
                mov     di, ax

                add     di, 5 * 80*2    ; add 5 lines

                pop     ax              ; restore ax

                ret
                endp



;------------------------------------------------
; Put into ES:DI line beginning addr of str
; Entry:    BP      - frame hight
; Exit:     ES:DI   - line beginning addr
; Destr:    CX BX AX
;------------------------------------------------
PutLBS          proc

                mov al, 24h             ; --| calculate length of string
                xor cx, cx              ;   |
                dec cx                  ;   |
                repne scasb             ;   |
                neg cx                  ;   |
                sub cx, 2h              ; --| cx - length of string

                mov bx, 2               ; --| calculate how many lines we should skip to be in the center of frame 
                mov ax, 80              ;   |
                sub ax, cx              ;   |
                div bx                  ;   |
                mul bx                  ;   |
                mov di, ax              ; --|

                mov ax, bp              ; --| calculate center of the current line
                div bx                  ;   |
                inc ax                  ;   |
                mov bx, 80*2            ;   |
                mul bx                  ;   |
                add di, ax              ; --|

                add di, 5 * 80*2        ; add five lines

                ret
                endp



;------------------------------------------------
; Write string in frame in video mem
; Entry:    BP      - frame hight
;           DS:DI   - addr of string
; Exit:     None
; Destr:    CX BX AX
;------------------------------------------------
DrawStr         proc

                mov si, di              ; DS:SI - addr of string

                push ax
                call PutLBS             ; Put into ES:DI line beginning addr of str
                pop ax

                mov     bx, 0b800h      ; --| go into video mem
                mov     es, bx          ; --|

Miu:            lodsb                   ; --| print string in video mem
                stosw                   ;   |
                loop Miu                ; --|

                ret
                endp



end Start