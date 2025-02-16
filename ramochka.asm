.model tiny
.code
.186
org 100h

Start:  mov ah, 01100010b
        mov si, offset String
        mov bx, 5h
        mov bp, 3h
        mov di, 0b800h
        mov es, di
        mov di, 20 * 80*2 + 40*2
        call DrawRam

        mov ax, 4c00h
        int 21h

String: db '2022 2202$'

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

;------------------------------------------------
; Draw a ramochka in video mem
; Entry:    AH    - color attr
;           DS:SI - addr of 9-byte ASCII seg to draw a frame
;           BX    - line length
;           BP    - hight
;           ES:DI - line beginning addr
; Exit:     None
; Destr:    AL CX SI DI DX
;------------------------------------------------
DrawRam     proc

            mov cx, bx
            mov dx, di
            call DrawLine
            mov di, dx
            add di, 80*2

Miu:        mov cx, bx
            mov dx, di
            call DrawLine
            mov cx, bp
            sub bp, 1
            sub si, 3
            mov di, dx
            add di, 80*2
            loop Miu

            add si, 3
            mov cx, bx
            call DrawLine

            ret
            endp

end Start


bluaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaat