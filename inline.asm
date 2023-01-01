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

public inline_x,inline_y,inline_chat,show_player_name,inline_clear,other_inline

extrn player_name:byte
extrn other_player_name:byte

.MODEL small
.stack 64
.DATA 
inline_x db 25
inline_y db 1

inline_x2 db 25
inline_y2 db 13
inline_line db "_______________$"

.code
inline_clear proc far
    ;clears the chat and return the cursor to the start of it
    mov inline_x,25
    mov inline_y,2

    mov ax,0600h
    mov bh,0
    mov cl,25
    mov ch,2
    mov dl,39
    mov dh,10
    int 10h
    ret
inline_clear endp

inline_clear2 proc far
    ;clears the chat and return the cursor to the start of it
    mov inline_x2,25
    mov inline_y2,13

    mov ax,0600h
    mov bh,0
    mov cl,25
    mov ch,13
    mov dl,39
    mov dh,21
    int 10h
    ret
inline_clear2 endp

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

inline_move_cursor2 proc
    push_all
    mov ah,02h
    mov bh,0
    mov dl,inline_x2
    mov dh,inline_y2
    int 10h
    pop_all
    ret
inline_move_cursor2 endp

show_player_name proc far
    ;shows player names in the inline chat and the lines in the middle
    push_all
    mov ah,9
    mov inline_x,25

    mov dx,offset inline_line
    mov inline_y,11
    call inline_move_cursor
    int 21h

    mov dx,offset inline_line
    mov inline_y,22
    call inline_move_cursor
    int 21h

    mov dx,offset player_name[2]
    mov inline_y,1
    call inline_move_cursor 
    int 21h

    mov dx,offset other_player_name
    mov inline_y,12
    call inline_move_cursor 
    int 21h
    
    mov inline_y,2
    pop_all
    ret
show_player_name endp

other_inline proc far
    ;to be used later
    cmp ah,1ch
    je enter_inline_endl2

    cmp ah,0eh
    je backspace_inline2

    ;moving the cursor to inline_x,inline_y then printing the character
    call inline_move_cursor2

    mov dl,al
    mov ah,2
    int 21h

    one_space2:
    inc inline_x2
    cmp inline_x2,40 ;if we have reached the end of the line we move to the next one
    je inline_endl2
    ret

    ;player pressed backspace
    backspace_inline2:
    cmp inline_x2,25
    je start_of_line2
    dec inline_x2
    jmp not_start_of_line2

    ;start of line so we go to the end of the previous line
    start_of_line2:
    cmp inline_y2,13
    je not_start_of_line2 ;start of chat so we do nothing
    dec inline_y2
    mov inline_x2,39

    not_start_of_line2:
    call inline_move_cursor2
    mov dl,32
    mov ah,2
    int 21h 
    ret

    ;we do the same as normal inline_endl and then print the player name
    enter_inline_endl2:
    mov inline_x2,25
    inc inline_y2
    cmp inline_y2,22
    je full_chat2
    ret

    ;user have reached the end of the line or pressed enter
    inline_endl2:
    mov inline_x2,25
    inc inline_y2
    cmp inline_y2,22
    je full_chat2
    ret

    full_chat2:
    call inline_clear2
    ret
other_inline endp

inline_chat proc far
    cmp ah,1ch
    je enter_inline_endl

    cmp ah,0eh
    je backspace_inline

    ;moving the cursor to inline_x,inline_y then printing the character
    call inline_move_cursor

    mov dl,al
    mov ah,2
    int 21h

    one_space:
    inc inline_x
    cmp inline_x,40 ;if we have reached the end of the line we move to the next one
    je inline_endl
    ret

    ;player pressed backspace
    backspace_inline:
    cmp inline_x,25
    je start_of_line
    dec inline_x
    jmp not_start_of_line

    ;start of line so we go to the end of the previous line
    start_of_line:
    cmp inline_y,2
    je not_start_of_line ;start of chat so we do nothing
    dec inline_y
    mov inline_x,39

    not_start_of_line:
    call inline_move_cursor
    mov dl,32
    mov ah,2
    int 21h 
    ret

    ;we do the same as normal inline_endl and then print the player name
    enter_inline_endl:
    mov inline_x,25
    inc inline_y
    cmp inline_y,11
    je full_chat
    ret

    ;user have reached the end of the line or pressed enter
    inline_endl:
    mov inline_x,25
    inc inline_y
    cmp inline_y,11
    je full_chat
    ret

    full_chat:
    call inline_clear
    ret
inline_chat endp
end