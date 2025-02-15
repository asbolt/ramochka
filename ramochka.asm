.model tiny
.code
.186
org 100h

Start:  mov ah, 11100010b
        mov si, offset String
        mov cx, 5h
        mov di, 0b800h
        mov es, di
        mov di, 5 * 80*2 + 40*2
        call DrawLine

        mov ax, 4c00h
        int 21h

String: db '101$'

;------------------------------------------------
; Draw a line in video meme
; Entry:    AH    - color attr
;           DS:SI - addr of 3-byte ASCII seg to draw a frame
;           CX    - line length
;           ES:DI - line beginning addr
; Exit:     None
; Destr:    AL CX SI DI
;------------------------------------------------
DrawLine    proc

            mov al, ds:[si]
            inc si

            mov es:[di], ax
            add di, 2

            mov al, ds:[si]
            inc si

Next:       mov es:[di], ax
            add di, 2
            loop Next

            mov al, ds:[si]
            inc si

            mov es:[di], ax
            add di, 2

            ret
            endp

end Start


bluaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaat