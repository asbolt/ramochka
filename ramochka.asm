.model tiny
.code
org 100h

Start:  mov ax, 0de41h              ; 'A' bright green omn magenta blinking
        call DrawChar

        mov ax, 4c00h
        int 21h

;------------------------------------------------
; Draw a char in video mem
; Entry: AL = char to write
;         AH = color attr
; Exit: None
; Destr: BX, ES
;------------------------------------------------
DrawChar    proc

            mov bx, 0b800h
            mov es, bx
            mov bx, 0h
            mov es:[bx], ax

            ret
            endp
;------------------------------------------------

end Start


bluaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaat