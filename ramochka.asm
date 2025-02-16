.model tiny
.code
.186
org 100h

Start:  mov ah, 11100010b
        mov si, offset Symbols
        mov cx, 0ch
        mov bx, 3h
        mov di, 0b800h
        mov es, di
        mov di, 80 - 2
        sub di, cx
        add di, 18 * 80*2

        push bx
        call DrawRam
        pop bx

        mov ah, 11100010b
        mov di, 5288h
        mov es, di
        mov di, offset String
        mov si, offset String
        call DrawStr

        mov ax, 4c00h
        int 21h

Symbols: db 'aaaa aaaa$'
String: db 'pizda$'

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
DrawLine    proc

            push cx

            lodsb
            stosw
            lodsb
            rep stosw
            lodsb
            stosw

            pop cx

            ret
            endp

;------------------------------------------------
; Draw a ramochka in video mem
; Entry:    AH    - color attr
;           DS:SI - addr of 9-byte ASCII seg to draw a frame
;           CX    - line length
;           BX    - hight
;           ES:DI - line beginning addr
; Exit:     None
; Destr:    AL CX SI DI BX
;------------------------------------------------
DrawRam     proc

            push di
            call DrawLine
            pop di
            add di, 80*2

            push cx

Next:       pop cx
            push di
            call DrawLine
            pop di
            add di, 80*2

            push cx
            mov cx, bx
            dec bx
            sub si, 3

            loop Next


            pop cx
            add si, 3
            call DrawLine

            ret
            endp

;------------------------------------------------
; Draw a string in video mem
; Entry:    AH    - color attr
;           BX    - ramochka hight
;           DS:SI - addr of string
;           ES:DI - addr of string
; Exit:     None
; Destr:    AL CX SI DI BX
;------------------------------------------------
DrawStr     proc

            mov di, si
            mov al, 24h
            xor cx, cx
            dec cx
            repne scasb
            neg cx
            sub cx, 2

            mov di, 0b800h
            mov es, di
            mov di, 80*2
            sub di, cx
            add di, 18 * 80*2

            push ax
            mov ax, bx
            mov bx, 80
            mul bx
            add di, ax
            mov bx, 2
            mov ax, di
            div bx
            mul bx
            mov di, ax
            pop ax

Miu:        lodsb
            stosw
            loop Miu

            ret
            endp

end Start


bluaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaat