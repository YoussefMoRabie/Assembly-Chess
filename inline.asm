;---------------------------Any Macros should be stored here------------------------------------------
PUSH_ALL MACRO 
            PUSH AX
            PUSH BX
            PUSH CX
            PUSH DX
            PUSH SI
            PUSH DI
ENDM PUSH_ALL

POP_ALL MACRO 
            POP DI
            POP SI
            POP DX
            POP CX
            POP BX
            POP AX
ENDM POP_ALL
;----------------------------------------------------------------------------------------------------

public inline_x,inline_y,inline_chat,show_player_name,inline_clear

extrn player_name:byte

.MODEL small
.stack 64
.DATA 
inline_x db 25
inline_y db 1

.code
inline_clear proc far
    ;clears the chat and return the cursor to the start of it
    mov inline_x,25
    mov inline_y,1

    mov ax,0600h
    mov bh,0
    mov cl,25
    mov ch,1
    mov dl,39
    mov dh,23
    int 10h
    ret
inline_clear endp

inline_move_cursor proc
    push_all
    mov ah,02h
    mov bh,0
    mov dl,inline_x
    mov dh,inline_y
    int 10h
    pop_all
    ret
inline_move_cursor endp

show_player_name proc far
    ;shows "player_name": before every message so we know the sender
    push_all
    mov bx,2
    mov ah,2
    mov inline_x,25

    printing_name:
    call inline_move_cursor
    mov dl,player_name[bx]
    cmp dl,13                   ;half enter
    je printed_name
    int 21h
    inc inline_x
    inc bx
    jmp printing_name

    printed_name:
    mov dl,':'
    int 21h
    inc inline_x
    pop_all
    ret
show_player_name endp

inline_chat proc far
    cmp ah,1ch
    je enter_inline_endl

    ;moving the cursor to inline_x,inline_y then printing the character
    call inline_move_cursor

    mov dl,al
    mov ah,2
    int 21h

    inc inline_x
    cmp inline_x,40 ;if we have reached the end of the line we move to the next one
    je inline_endl
    ret

    ;we do the same as normal inline_endl and then print the player name
    enter_inline_endl:
    mov inline_x,25
    inc inline_y
    cmp inline_y,24
    je full_chat
    call show_player_name
    ret

    ;user have reached the end of the line or pressed enter
    inline_endl:
    mov inline_x,25
    inc inline_y
    cmp inline_y,24
    je full_chat
    ret

    full_chat:
    call inline_clear
    call show_player_name
    ret
inline_chat endp
end