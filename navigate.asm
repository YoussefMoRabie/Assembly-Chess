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

public player_name,other_player_name

.MODEL small
.stack 64

.DATA 
player_name db 100,?,98 dup('$')
other_player_name db 20 dup('$')
player_name_index db 2
other_player_name_index db 0
got_player_name db 0 ;checks if we got the other player name or not
sent_player_name db 0 ;checks if we sent our name to the other player or not
sent_first_letter db 0 
sent_inv db 0
recieved_inv db 0
temp_inv db 0
x db 0
y db 0
message_offset dw ?

;getting name messages
enter_name db "Please enter your name: $"
press_enter db "Press enter to continue. $"

;menu messages
welcome db "Welcome $"
message1 db "To Start Chatting Press F1$"
message2 db "To Start The Game (Send Invitation) Press F2$"
message3 db "To Start The Game (Same Device) Press F3$"
message4 db "To Exit The Program Press ESC$"
error_message db "Name length must not exceed 15 and begin with a character! $"

;notification bar
notification_bar db "Notification Bar: $"
notification_line db "________________________________________________________________________________$"
connection_msg db " - You are not connected to another device, press F3 to play on the same device$"
before_rec db " - $"
sent_game_inv_msg db " - You sent a game invitation to $"
recieved_game_inv_msg db " sent you a game invitation, press F2 to accept it $"
sent_chat_inv_msg db " - You sent a chat invitation to $"
recieved_chat_inv_msg db " sent you a chat invitation, press F1 to accept it $"

.code
reset_all proc
    call reset_game
    call reset_timer
    call inline_clear
    ret
reset_all endp

clear_sent_notifications proc
    push_all
    mov ax,0600h
    mov bh,7
    mov cl,0
    mov ch,23
    mov dl,79
    mov dh,23
    int 10h
    pop_all
    ret 
clear_sent_notifications endp

clear_rec_notifications proc
    push_all
    mov ax,0600h
    mov bh,7
    mov cl,0
    mov ch,24
    mov dl,79
    mov dh,24
    int 10h
    pop_all
    ret 
clear_rec_notifications endp


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

    mov x,0

    mov y,21
    mov message_offset,offset notification_line
    call show_message

    mov y,22
    mov message_offset,offset notification_bar
    call show_message

    call print_left_notifications
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
    
    cmp player_name[1],15
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

get_other_player_name proc
    ;gets the other player's name letter by letter
    push_all

    ;Check that Data Ready
    mov dx , 3FDH		; Line Status Register
    in al , dx 
    and al , 00000001b
    Jz getting_name_done

    ;If Ready read the VALUE in Receive data register
    mov dx , 3F8H
    in al , dx 

    cmp al,'$'
    je getting_name_done
    
    mov bl,other_player_name_index
    mov bh,0
    mov other_player_name[bx],al
    inc other_player_name_index

    ;half enter check - means name is done
    cmp al,13
    jne getting_name_done
    mov got_player_name,1
    mov other_player_name[bx],'$'

    getting_name_done:
    pop_all
    ret
get_other_player_name endp

send_player_name proc
;send your own name to the other player letter by letter
    push_all

;Check that Transmitter Holding Register is Empty
    mov dx , 3FDH		;Line Status Register
    In al , dx 			;Read Line Status

    and al , 00100000b
    Jz sending_name_done

    ;other player haven't connected yet
    cmp sent_first_letter,0
    je no_first_letter

    cmp other_player_name[0],'$'
    je sending_name_done
    no_first_letter:

    ;If empty put the VALUE in Transmit data register
    mov dx , 3F8H		; Transmit data register
    mov bl,player_name_index
    mov bh,0
    mov al,player_name[bx]
    out dx, al 
    inc player_name_index
    mov sent_first_letter,1

    ;half enter check - means name is done
    cmp player_name[bx],13
    jne sending_name_done
    mov sent_player_name,1

    sending_name_done:
    pop_all
    ret
send_player_name endp

send_chat_invitation proc
    push_all
    ;send a game invitaion
    mov dx , 3FDH		;Line Status Register
    In al , dx 			;Read Line Status
    AND al , 00100000b
    JZ chat_inv_done

    ;If empty put the invitaion in Transmit data register
    mov dx , 3F8H		;Transmit data register
    mov al,3bh
    out dx, al 

    mov sent_inv,1

    call clear_sent_notifications
    mov x,0
    mov y,23
    mov message_offset,offset sent_chat_inv_msg
    call show_message
    mov dx,offset other_player_name
    mov ah,9
    int 21h

    chat_inv_done:
    pop_all
    ret
send_chat_invitation endp


send_game_invitation proc
    push_all
    ;send a game invitaion
    mov dx , 3FDH		;Line Status Register
    In al , dx 			;Read Line Status
    AND al , 00100000b
    JZ game_inv_done

    ;If empty put the invitaion in Transmit data register
    mov dx , 3F8H		;Transmit data register
    mov al,3ch
    out dx, al 

    mov sent_inv,2

    call clear_sent_notifications
    mov x,0
    mov y,23
    mov message_offset,offset sent_game_inv_msg
    call show_message
    mov dx,offset other_player_name
    mov ah,9
    int 21h

    game_inv_done:
    pop_all
    ret
send_game_invitation endp

recieve_invitaions proc
    push_all
    mov bl,recieved_inv
    mov temp_inv,bl
    ;Check that Data Ready
    mov dx , 3FDH		; Line Status Register
    in al , dx 
    AND al , 1
    JZ recieve_inv_done

    ;If Ready read the VALUE in Receive data register
    mov dx , 3F8H
    in al , dx 

    cmp al,3bh
    je recieved_chat_inv

    cmp al,3ch
    je recieved_game_inv

    ;no invitiaions recieved
    jmp recieve_inv_done


    recieved_chat_inv:
    call clear_rec_notifications
    mov x,0
    mov y,24
    mov message_offset,offset before_rec
    call show_message
    
    mov dx,offset other_player_name
    mov ah,9
    int 21h

    mov dx,offset recieved_chat_inv_msg
    mov ah,9
    int 21h

    mov recieved_inv,1
    cmp sent_inv,1
    je start_chat

    jmp recieve_inv_done
    ;-----------------------------------------------------------------------
    recieved_game_inv:
    call clear_rec_notifications
    mov x,0
    mov y,24
    mov message_offset,offset before_rec
    call show_message

    mov dx,offset other_player_name
    mov ah,9
    int 21h


    mov dx,offset recieved_game_inv_msg
    mov ah,9
    int 21h
    
    mov recieved_inv,2
    cmp sent_inv,2
    je start_game

    recieve_inv_done:
    pop_all
    ret

    start_chat:
    mov sent_inv,0
    mov bl,temp_inv
    mov recieved_inv,bl
    ;@mahmoud yehia
    pop_all
    ret

    start_game:
    ;wasting some frames for both to start together
    mov cx,400
    waste_time:
    loop waste_time

    mov sent_inv,0
    mov bl,temp_inv
    mov recieved_inv,bl
    call reset_all
    mov player_mode,1
    call play
    call menu
    pop_all
    ret
recieve_invitaions endp

print_no_connection proc
    call clear_sent_notifications
    mov x,0
    mov y,23
    mov message_offset,offset connection_msg
    call show_message
    ret
print_no_connection endp

print_left_notifications proc
    ;prints unanswered notifications when we go back to menu
    push_all

    cmp sent_inv,1
    jne no_sent_chat
    call clear_sent_notifications
    mov x,0
    mov y,23
    mov message_offset,offset sent_chat_inv_msg
    call show_message
    mov dx,offset other_player_name
    mov ah,9
    int 21h
    no_sent_chat:

    cmp sent_inv,2
    jne no_sent_game
    call clear_sent_notifications
    mov x,0
    mov y,23
    mov message_offset,offset sent_game_inv_msg
    call show_message
    mov dx,offset other_player_name
    mov ah,9
    int 21h
    no_sent_game:

    cmp recieved_inv,1
    jne no_rec_chat
    ;rec chat invitation
    call clear_rec_notifications
    mov x,0
    mov y,24
    mov message_offset,offset before_rec
    call show_message
    mov dx,offset other_player_name
    mov ah,9
    int 21h
    mov dx,offset recieved_chat_inv_msg
    mov ah,9
    int 21h
    no_rec_chat:

    cmp recieved_inv,2
    jne no_rec_game
    call clear_rec_notifications
    mov x,0
    mov y,24
    mov message_offset,offset before_rec
    call show_message
    mov dx,offset other_player_name
    mov ah,9
    int 21h
    mov dx,offset recieved_game_inv_msg
    mov ah,9
    int 21h
    no_rec_game:

    pop_all
    ret
print_left_notifications endp

wait_key proc
    ;gets the key pressed then calls the appropriate function

    ;send your name and try to get the other player's name 
    cmp got_player_name,1
    je got_name
    call get_other_player_name
    got_name:
    cmp sent_player_name,1
    je sent_name
    call send_player_name
    sent_name:

    ;recieving game and chat invs
    cmp got_player_name,0
    je no_other_name_yet
    call recieve_invitaions
    no_other_name_yet:

    ;waiting for inputs
    mov ah,1
    int 16h
    jz no_key_pressed_menu
    mov ah,0
    int 16h

    cmp ah, 01h
    je terminate

    cmp ah,3dh
    je game

    cmp ah,3bh
    je chat_module

    cmp ah,3ch
    je two_player_game


    ;key pressed doesn't do anything
    no_key_pressed_menu:
    ret

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
    ret

    chat_module:
    cmp sent_player_name,0
    je no_connection
    ;to keep current sent inv in case of return to menu
    mov bl,sent_inv
    mov temp_inv,bl
    call send_chat_invitation

    cmp recieved_inv,1
    jne no_key_pressed_menu
    mov recieved_inv,0
    mov bl,temp_inv
    mov sent_inv,bl
    ;@mahmoud yehia
    ret

    two_player_game:
    cmp sent_player_name,0
    je no_connection
    ;to keep current sent inv in case of return to menu
    mov bl,sent_inv
    mov temp_inv,bl
    call send_game_invitation


    cmp recieved_inv,2
    jne no_key_pressed_menu
    mov recieved_inv,0
    mov bl,temp_inv
    mov sent_inv,bl
    call reset_all
    mov player_mode,2
    call play
    call menu
    ret

    no_connection:
    call print_no_connection
    ret 
wait_key endp

start proc far
    mov ax,@data
    mov ds,ax

    ;initinalize COM
    ;Set Divisor Latch Access Bit
    mov dx,3fbh 			; Line Control Register
    mov al,10000000b		;Set Divisor Latch Access Bit
    out dx,al				;Out it
    ;Set LSB byte of the Baud Rate Divisor Latch register.
    mov dx,3f8h			
    mov al,0ch			
    out dx,al

    ;Set MSB byte of the Baud Rate Divisor Latch register.
    mov dx,3f9h
    mov al,00h
    out dx,al

    ;Set port configuration
    mov dx,3fbh
    mov al,00011011b
    out dx,al

    call get_player_name
    call menu
    menu_wait:
        call wait_key
    jmp menu_wait
start endp
end start
