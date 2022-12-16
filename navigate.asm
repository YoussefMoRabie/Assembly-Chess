include macros.inc
extrn play:far
extrn init_draw:far
extrn player_mode:byte

.MODEL small
.stack 64

.DATA 
x db 0
y db 0
message_offset dw ?
message1 db "To Start Chatting Press F1$"
message2 db "To Start The Game (Send Invitation) Press F2$"
message3 db "To Start The Game (Same Device) Press F3$"
message4 db "To Exit The Program Press ESC$"
.code

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

    call menu
    menu_wait:
        call wait_key
    jmp menu_wait
start endp
end start
