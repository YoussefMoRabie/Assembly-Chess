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
extrn play:far
extrn init_draw:far
extrn reset_game:far
extrn reset_timer:far
extrn inline_clear:far
extrn player_mode:byte

public player_name

.MODEL small
.stack 64

.DATA 
player_name db 100,?,98 dup('$')
x db 0
y db 0
message_offset dw ?

enter_name db "Please enter your name: $"
press_enter db "Press enter to continue. $"

welcome db "Welcome $"
message1 db "To Start Chatting Press F1$"
message2 db "To Start The Game (Send Invitation) Press F2$"
message3 db "To Start The Game (Same Device) Press F3$"
message4 db "To Exit The Program Press ESC$"
error_message db "Name lenght must not exceed 13 and begin with a character! $"

.code

reset_all proc
    call reset_game
    call reset_timer
    call inline_clear
    ret
reset_all endp

Show_Message proc far
    PUSH_ALL
    ;set cursor at x and y
    mov ah,02h
    mov bh,0
    mov dl,x
    mov dh,y
    int 10h

    ;print the message with the offset stored in message_offset
    mov ah,9h
    mov dx, message_offset
    int 21h
    POP_ALL
    ret
show_message endp

menu proc
    ;goes to text mode and initializes the menu
    push_all
    mov ah,0
    mov al,3
    int 10h

    mov ch, 32
    mov ah, 1
    int 10h 

    mov x,0
    mov y,0
    mov message_offset, offset welcome
    call show_message
    mov x,8
    mov message_offset,offset player_name[2]
    call show_message

    mov x,15

    mov y,7
    mov message_offset,offset message1
    call show_message
    
    mov y,10
    mov message_offset,offset message2
    call show_message
   
    mov y,13
    mov message_offset,offset message3
    call show_message
   
    mov y,16
    mov message_offset,offset message4
    call show_message
    pop_all
    ret
menu endp

name_error proc
    push_all
    mov x,15
    mov y,12
    mov message_offset,offset error_message
    call show_message
    
    ;erasing the player name
    mov cx,98
    mov bx,2

    erase_name:
    mov player_name[bx],'$'
    inc bx
    loop erase_name

    ;ersing it from screen
    mov ax,0600h
    mov bh,7
    mov cl,15
    mov ch,11
    mov dl,79
    mov dh,11
    int 10h

    ;returning the cursor to place 
    mov ah,02h
    mov bh,0
    mov dl,15
    mov dh,11
    int 10h
    
    pop_all
    ret
name_error endp

get_player_name proc
    push_all
    mov ah,0
    mov al,3
    int 10h

    mov ch, 32
    mov ah, 1
    int 10h 

    mov x,15
    mov y,10
    mov message_offset,offset enter_name
    call show_message

    mov y,16
    mov message_offset,offset press_enter
    call show_message
    
    mov ah,02h
    mov bh,0
    mov dl,15
    mov dh,11
    int 10h

    ;looping till the entered name is correct

    name_error_loop:
    mov ah,0ah
    mov dx,offset player_name
    int 21h
    
    cmp player_name[1],13
    jg yes_name_error
    cmp player_name[2],122
    jg yes_name_error
    cmp player_name[2],65
    jl yes_name_error
    cmp player_name[2],91
    je yes_name_error
    cmp player_name[2],92
    je yes_name_error
    cmp player_name[2],93
    je yes_name_error
    cmp player_name[2],94
    je yes_name_error
    cmp player_name[2],95
    je yes_name_error
    cmp player_name[2],96
    je yes_name_error

    jmp no_name_error

    yes_name_error:
    call name_error
    jmp name_error_loop

    no_name_error:
    pop_all
    ret
get_player_name endp

wait_key proc
    ;gets the key pressed then calls the appropriate function
    mov ah,1
    int 16h
    jz no_key_pressed_menu
    mov ah,0
    int 16h

    cmp ah, 01h
    je terminate

    cmp ah,3dh
    je game

    ;key pressed doesn't do anything
    jmp no_key_pressed_menu

    Game:
    call reset_all
    mov player_mode,0
    call play
    call menu
    ret

    terminate:
    mov ah,0
    mov al,3
    int 10h
    mov ah,4ch
    int 21h
    
    no_key_pressed_menu:
    ret
wait_key endp

start proc far
    mov ax,@data
    mov ds,ax

    call get_player_name
    call menu
    menu_wait:
        call wait_key
    jmp menu_wait
start endp
end start
