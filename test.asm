.model tiny
.code
.186
org 100h

Start:  mov ah, 11100010b
        mov di, offset String
        mov si, offset String
        call DrawStr

        mov ax, 4c00h
        int 21h

String: db 'h23457$'

;------------------------------------------------
; Draw a string in video mem
; Entry:    AH    - color attr
;           DS:SI - addr of string
;           ES:DI - line beginning addr
; Exit:     None
; Destr:    
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
            mov di, 80
            sub di, cx
            add di, 80*2 *20

            push ax
            mov ax, di
            mov di, 2
            sum ax, ax

Miu:        lodsb
            stosw
            loop Miu

            ret
            endp

end Start


bluaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaat