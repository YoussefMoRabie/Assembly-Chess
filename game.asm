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

extrn PrintWinner:far
extrn init_draw:far
extrn draw_cell:far
extrn get_cell_start:far
extrn draw_selector1:far
extrn draw_selector2:far
extrn move_piece:far
extrn draw_W_from_cell:far
extrn draw_B_from_cell:far
extrn draw_W_to_cell:far
extrn draw_B_to_cell:far
extrn check_W_piece:far
extrn move_piece_:far
extrn draw_W_from_cell_:far
extrn draw_B_from_cell_:far
extrn draw_W_to_cell_:far
extrn draw_B_to_cell_:far
extrn check_B_piece:far
extrn inline_chat:far
extrn show_player_name:far
extrn draw_white_valid:far
extrn draw_black_valid:far
extrn Timer:far
extrn PrintBlackKilled:far
extrn PrintWhiteKilled:far
extrn other_inline:far


extrn white_deselector:byte
extrn black_deselector:byte
extrn locker:byte
extrn unlocker_black:byte
extrn unlocker_white:byte
extrn Star:byte
extrn bKing:byte
extrn wKing:byte
extrn bQueen:byte
extrn wQueen:byte
extrn bRook:byte
extrn wRook:byte
extrn bBishop:byte
extrn wBishop:byte
extrn bKnight:byte
extrn wKnight:byte
extrn bPawn:byte
extrn wPawn:byte
extrn bSquare:byte
extrn wSquare:byte
extrn selector1:byte
extrn selector2:byte
extrn KilledBlack:byte
extrn KilledWhite:byte



extrn shape_to_draw:word
extrn row:word
extrn col:word

extrn cell_start:word
extrn inline_x:byte
extrn inline_y:byte



public s1_row, s1_col, s2_row, s2_col,valid_col,piece_type,valid_row, player_mode,play,boardMap,from_row,from_col,to_row
public to_col,wFound,bFound,boardMap,wPiece,bPiece,from_row_,from_col_,to_row_,to_col_,update_Last_move_time,EndGame,reset_game

.MODEL small
.stack 64
.DATA 
player_mode db 3    ;both_players:0 player1:1 player2:2 return_to_menu:3 
;---------------------------- move from cell to cell ----------------------------
from_row dw 8
from_col dw 8
valid_row db 8  ; row of the valid cell to be drawn
valid_col db 8  ; column of the valid cell to be drawn
Wking_row db 7 
Wking_col db  4
Bking_row db 0 
Bking_col db  4
W_threat db 0
B_threat db 0
bishop_Rook_flag db 1
W_threat_p db 00
B_threat_p db 00
from_color dw 0 
to_row dw 0
to_col dw 0
to_color dw 0 
wFound dw 0 
wPiece dw 0
bPiece dw 0
piece_type db 00  ; code for the piece selected
Bpiece_type db 00 ; code of selected black piece 
Wpiece_type db 00 ; code for selected white piece
bFound dw 0       
from_row_ dw 8
from_col_ dw 8
from_color_ dw 0 
to_row_ dw 0
to_col_ dw 0
to_color_ dw 0 
del_row dw 0 
del_col dw 0 
;-----------------------------------------------------------------------------
player_chat db 0
s1_row dw 7
s1_col dw 4
s1_color db 0       ;the cell color s1 is standing on, 0:black 0ffh:white
s2_row dw 0
s2_col dw 4
s2_color db 0ffh    ;the cell color s2 is standing on, 0:balck 0ffh:white
direction db 0      ;up:0 down:1 left:2 right:3
valid db 1 ;input for macro to return 1 or 0 based on cell position
marked db 0 
EndGame db 0   ; if EndGame==0A --> white win

from_cell db 0
to_cell db 0

WFT db 3  ; White Freezing Time
BFT db 3 ; Black Freezing Time


W_threat_MSG db "White checked$"
B_threat_MSG db "Black checked$"
clean_threat db "             $"

init_boardMap label byte  ;used for resetting the game
        db 01h, 02h, 03h, 0Bh, 0Ah, 13h, 12h, 11h
        db 40h, 41h, 42h, 43h, 44h, 45h, 46h, 47h
        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        db 50h, 51h, 52h, 53h, 55h, 55h, 56h, 57h
        db 21h, 22h, 23h, 1Bh, 1Ah, 33h, 32h, 31h

boardMap label byte
        db 01h, 02h, 03h, 0Bh, 0Ah, 13h, 12h, 11h
        db 40h, 41h, 42h, 43h, 44h, 45h, 46h, 47h
        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        db 50h, 51h, 52h, 53h, 55h, 55h, 56h, 57h
        db 21h, 22h, 23h, 1Bh, 1Ah, 33h, 32h, 31h
;;; We have 2 digit. LSB represent the type of piece and MSB represent piece ID
;LSB : 1 for rock. MSB: 0,1 for black 2,3 for white so 01--> first black rock, 11--> second black rock, 21--> first white rock, 31--> second white rock
;LSB : 2 for knight. MSB: 0,1 for black 2,3 for white so 02--> first black knight, 12--> second black knight, 22--> first white knight, 32--> second white knight
;LSB : 3 for bishop. MSB: 0,1 for black 2,3 for white so 03--> first black bishop, 13--> second black bishop, 23--> first white bishop, 33--> second white bishop
;Lsb : A for King. MSB: 0 for black 1 for white so 0A--> first black King, 1A--> second wight King
;Lsb : B for Queen. MSB: 0 for black 1 for white so 0B--> first black Queen, 1B--> second wight Queen
;Lsb : 4 for pawns. MSB: from 0 to 7 represent black pawns 
;Lsb : 5 for pawns. MSB: from 0 to 7 represent white pawns 
;; AA : is a star 
;--------------------- FREEZING
LastMoveTime label byte
        dw 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        dw 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        dw 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        dw 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        dw 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        dw 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        dw 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        dw 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
        ;--------------------------
knightOffset label byte  ; valid offsets for knight moves
            db 1,-2
            db -1,-2
            db -1,2
            db 1,2
            db 2,1
            db 2,-1
            db -2,-1
            db -2,1
kingOffset label byte ; valid offsets for king moves
            db 1,1
            db 1,0
            db 1,-1
            db -1,1
            db -1,0
            db -1,-1
            db 0,-1
            db 0,1

bishopOffset label byte ; valid offsets for bishop moves
           db -1,1
            db 1,1
            db 1,-1
            db -1,-1
            

RookOffset label byte   ; valid offsets for rook moves
            db 1,0
            db -1,0
            db 0,1
            db 0,-1

selectorMap label byte   ;map for the cell having highlight for being valid
        db 8 dup(00h)
        db 8 dup(00h)
        db 8 dup(00h)
        db 8 dup(00h)
        db 8 dup(00h)
        db 8 dup(00h)
        db 8 dup(00h)
        db 8 dup(00h)
; for valid cells
; 00h --> does not have any selector drawn
; 01h --> have a selector for white
; 10h --> have a selector for black
; 11h --> have overlapping selector

.code
;scan codes in hex
;w:11   s:1f    a:1e    d:20     q:10   1:02
;up:48 down:50 left:4b right:4d r_shift:36 

reset_game proc far
  ;resets all game variables to their initial values
  push_all
  mov player_mode, 3 
  mov from_row, 8
  mov from_col, 8
  mov valid_row, 8
  mov valid_col, 8
  mov from_color, 0 
  mov to_row, 0
  mov to_col, 0
  mov to_color, 0 
  mov Wking_row , 7 
  mov Wking_col ,  4
  mov Bking_row , 0 
  mov Bking_col ,  4
  mov bishop_Rook_flag , 1
  mov W_threat , 0
  mov B_threat , 0
  mov bishop_Rook_flag , 1
  mov W_threat_p , 00
  mov B_threat_p , 00
  mov wFound, 0 
  mov wPiece, 0
  mov bPiece, 0
  mov piece_type, 00
  mov Bpiece_type, 00
  mov Wpiece_type, 00
  mov bFound, 0 
  mov from_row_, 8
  mov from_col_, 8
  mov from_color_, 0 
  mov to_row_, 0
  mov to_col_, 0
  mov to_color_, 0 
  mov player_chat, 0
  mov s1_row, 7
  mov s1_col, 4
  mov s1_color, 0       
  mov s2_row, 0
  mov s2_col, 4
  mov s2_color, 0ffh    
  mov direction, 0    
  mov valid, 1 
  mov marked, 0 
  mov EndGame, 0 
  mov WFT, 3  
  mov BFT, 3

  mov ax,@data
  mov es,ax
  
  mov di,offset boardMap
  mov si,offset init_boardmap
  mov cx,32
  rep movsw
  
  mov di,offset LastMoveTime
  mov al,0
  mov cx,32
  rep stosw

  mov di,offset selectorMap
  mov al,0
  mov cx,32
  rep stosw

  pop_all
  ret
reset_game endp

;-----------------------------------listener for both players, changed with player mode-------------------------------------------
player_movement proc far
    ;gets the key pressed and checks if it concerns a player, then calls the appropriate function
    mov ah,1
    int 16h
    jz no_key_pressed_game
    mov ah,0
    int 16h

    ;listens depending on the player_mode
    cmp player_mode,1
    je two_player_mode1
    cmp player_mode,2
    je two_player_mode2

    ;-------------------------------------------------single device mode---------------------------------------------------------------
    ;player pressed f4
    cmp ah,3eh
    jne not_menu
    jmp game_to_menu
    not_menu:

    ;WASD + Q for player 1
    cmp ah,11h
    je up1
    cmp ah,1fh
    je down1
    cmp ah,1eh
    je left1
    cmp ah,20h
    je right1
    cmp ah,10h
    jne not_select1
    jmp select1
    not_select1:

    ;arrow keys + keypad_0 for player 2
    cmp ah,48h
    je up2
    cmp ah,50h
    je down2
    cmp ah,4bh
    je left2
    cmp ah,4dh
    je right2
    cmp ah,52h
    jne not_select2
    jmp select2
    not_select2:

    ;the key pressed doesn't concern players in single mode
    no_key_pressed_game:
    ret

    ;-------------------------------------------------------two device mode-------------------------------------------------------------
    ;arrow keys + keypad_0 for both players
    two_player_mode1:
    cmp ah,48h
    je up1
    cmp ah,50h
    je down1
    cmp ah,4bh
    je left1
    cmp ah,4dh
    je right1
    cmp ah,52h
    je select1
    jmp go_inline_chat
   
    two_player_mode2:
    cmp ah,48h
    je up2
    cmp ah,50h
    je down2
    cmp ah,4bh
    je left2
    cmp ah,4dh
    je right2
    cmp ah,52h
    je select2
    jmp go_inline_chat
   
    ;------------------------------------------------------------for either modes------------------------------------------------------------------
    up1:
    mov direction,0
    jmp move1
    down1:
    mov direction,1
    jmp move1
    left1:
    mov direction,2
    jmp move1
    right1:
    mov direction,3
    jmp move1

    up2:
    mov direction,0
    jmp move2
    down2:
    mov direction,1
    jmp move2
    left2:
    mov direction,2
    jmp move2
    right2:
    mov direction,3
    jmp move2

    select1:
    call Select_W
    ret

    select2:
    call Select_B
    ret

    move1:
    call move_selector1
    ret

    move2:
    call move_selector2
    ret   

    go_inline_chat:
    ;one of the players pressed f4
    cmp ah,3eh
    je game_to_menu

    ;a button that isn't f4 nor a movement/select so we send it to the chat
    call send_inline_chat
    call inline_chat
    ret

    ;player mode 3 is a code for returning to the menu
    game_to_menu:
    mov player_mode,3
    ret
player_movement endp
;--------------------------------------------------------------------------------------------------------------
send_inline_chat proc
  push_all
  ;sends inline chat letters
  mov cx,ax
  ;send a chat letter
  mov dx , 3FDH		;Line Status Register
  In al , dx 			;Read Line Status
  AND al , 00100000b
  JZ send_chat_done

  ;If empty put the invitaion in Transmit data register
  mov ax,cx
  mov dx , 3F8H		;Transmit data register
  out dx, al 

  send_chat_done:
  pop_all
  ret
send_inline_chat endp

send_movement proc
  push_all
  ;send from_cell and to_cell to the other player
  
  indicator_again:
  mov dx , 3FDH		;Line Status Register
  In al , dx 			;Read Line Status
  AND al , 00100000b
  JZ indicator_again

  mov dx , 3F8H		
  mov al,1
  out dx,al

  from_cell_again:
  mov dx , 3FDH		;Line Status Register
  In al , dx 			;Read Line Status
  AND al , 00100000b
  JZ from_cell_again
 
  mov dx , 3F8H		
  mov al,from_cell
  out dx,al

  to_cell_again:
  mov dx , 3FDH		;Line Status Register
  In al , dx 			;Read Line Status
  AND al , 00100000b
  JZ to_cell_again
  
  mov dx , 3F8H		
  mov al,to_cell
  out dx,al
 
  pop_all
  ret
send_movement endp

recieve_game proc
  push_all
  ;recieves inline chat letters
  ;Check that Data Ready
  mov dx , 3FDH		;Line Status Register
  in al , dx 
  and al , 00000001b
  Jnz recieve_game_con
  jmp End_recieve_game
  recieve_game_con:
  ;If Ready read the VALUE in Receive data register
  mov dx , 3F8H
  in al , dx 
  
  ;other player pressed F4
  cmp al,7
  jne rec_not_menu
  mov player_mode,3
  ret
  rec_not_menu:

  cmp al,13
  jne rec_not_enter
  mov ah,1ch
  rec_not_enter:

  cmp al,8
  jne rec_not_back
  mov ah,0eh
  rec_not_back:
  
  ;other player is sending a move
  cmp al,1
  je recieve_movement

  call other_inline
  jmp End_recieve_game

  recieve_movement:
  ;we loop until we get the from_cell and to_cell from the other player 
  recieve_from_again:
  mov dx , 3FDH		;Line Status Register
  in al , dx 
  and al , 00000001b
  Jz recieve_from_again

  mov dx,3f8h
  in al,dx
  cmp player_mode,2
je get_white
  mov ah,0
  mov dh,8
  div dh
  mov cx,0
  mov cl,al
  mov from_row_,cx
  mov cl,ah
  mov from_col_,cx

  recieve_to_again:
  mov dx , 3FDH		;Line Status Register
  in al , dx 
  and al , 00000001b
  Jz recieve_to_again

  mov dx,3f8h
  in al,dx

  mov ah,0
  mov dh,8
  div dh
  mov cx,0
  mov cl,al
  mov to_row_,cx
  mov cl,ah
  mov to_col_,cx
  
  call move_black
  jmp End_recieve_game
get_white:
  mov ah,0
  mov dh,8
  div dh
  mov cx,0
  mov cl,al
  mov from_row,cx
  mov cl,ah
  mov from_col,cx

  recieve_to_again_:
  mov dx , 3FDH		;Line Status Register
  in al , dx 
  and al , 00000001b
  Jz recieve_to_again_

  mov dx,3f8h
  in al,dx

  mov ah,0
  mov dh,8
  div dh
  mov cx,0
  mov cl,al
  mov to_row,cx
  mov cl,ah
  mov to_col,cx
  
  call move_white


  End_recieve_game:
  pop_all
  ret
recieve_game endp
;-------------------------------------------player 1-----------------------------------------------------------
move_selector1 proc
    ;moves the selector1 in the direction in variable "direction"
    call deselect1
    not s1_color

    cmp direction,0
    je move_up1
    cmp direction,1
    je move_down1
    cmp direction,2
    je move_left1
    cmp direction,3
    je move_right1
    
    move_up1:
    dec s1_row
    cmp s1_row,0
    jge within_boundary1
    mov s1_row,7
    jmp within_boundary1

    move_down1:
    inc s1_row
    cmp s1_row,8
    jl within_boundary1
    mov s1_row,0
    jmp within_boundary1

    move_left1:
    dec s1_col
    cmp s1_col,0
    jge within_boundary1
    mov s1_col,7
    jmp within_boundary1
    
    move_right1:
    inc s1_col
    cmp s1_col,8
    jl within_boundary1
    mov s1_col,0
    jmp within_boundary1

    within_boundary1:
    call draw_selector1
    ret
move_selector1 endp

deselect1 proc
    push ax

    cmp s1_color,0
    je black_cell1
    mov shape_to_draw, offset white_deselector
    jmp white_cell1
    black_cell1:
    mov shape_to_draw, offset black_deselector
    white_cell1:
    
    mov ax,s1_col
    mov col,ax
    mov ax,s1_row
    mov row,ax
    call draw_cell

    mov ax,s1_row
    cmp ax,s2_row
    jne deselect1_chOv
    mov ax,s1_col
    cmp ax,s2_col
    jne deselect1_chOv
    ;both selectors overlapped, so we draw the other selector since we just erased it
    call draw_selector2
    jmp no_overlapping1

    deselect1_chOv: ;checking if there is overlapping between the selector and white highlighted cells and if so, draw the highlight again
    mov si,offset selectorMap
    mov ax,s1_row
    mov cx, s1_col
    mov dx,8d
    mul dl
    add ax,cx
    add si,AX
    mov al,10h
    cmp [si],al
    mov bx,s1_row
    mov valid_row,bl
    mov valid_col,cl
    jne deselect1_chOv2
    call draw_white_valid
    jmp no_overlapping1 
    
 deselect1_chOv2:  ;checking if there is overlapping between the selector and black highlighted cells and if so, draw the highlight again
    mov al,01h
    cmp [si],al
    jne deselect1_overlpValid
    call draw_black_valid
    jmp no_overlapping1

   deselect1_overlpValid: ;checking if there is overlapping between the selector and black&white highlighted cells and if so, draw the highlight again
    mov al,11h  
    cmp [si],al
    jne no_overlapping1
        call draw_white_valid
        call draw_black_valid

    no_overlapping1:
    pop ax
    ret
deselect1 endp

deselect_valid1 proc ; removes the highlight valid cell

push ax

    cmp s1_color,0
    je black_cell11
    mov shape_to_draw, offset white_deselector
    jmp white_cell11
    black_cell11:
    mov shape_to_draw, offset black_deselector
    white_cell11:
    
    mov ax,s1_col
    mov col,ax
    mov ax,s1_row
    mov row,ax
    call draw_cell

    mov ax,s1_row
    cmp ax,s2_row
    jne no_overlapping11
    mov ax,s1_col
    cmp ax,s2_col
    jne no_overlapping11
    ;both selectors overlapped, so we draw the other selector since we just erased it
    call draw_selector2
    jmp no_overlapping11


    no_overlapping11:
    pop ax
    ret
deselect_valid1 endp
;-------------------------------------------------player 2----------------------------------------------------------------
move_selector2 proc
    ;moves the selector1 in the direction in variable "direction"
    call deselect2
    not s2_color

    cmp direction,0
    je move_up2
    cmp direction,1
    je move_down2
    cmp direction,2
    je move_left2
    cmp direction,3
    je move_right2
    
    move_up2:
    dec s2_row
    cmp s2_row,0
    jge within_boundary2
    mov s2_row,7
    jmp within_boundary2

    move_down2:
    inc s2_row
    cmp s2_row,8
    jl within_boundary2
    mov s2_row,0
    jmp within_boundary2

    move_left2:
    dec s2_col
    cmp s2_col,0
    jge within_boundary2
    mov s2_col,7
    jmp within_boundary2
    
    move_right2:
    inc s2_col
    cmp s2_col,8
    jl within_boundary2
    mov s2_col,0
    jmp within_boundary2

    within_boundary2:
    call draw_selector2
    ret
move_selector2 endp

deselect2 proc
    push ax

    cmp s2_color,0
    je black_cell2
    mov shape_to_draw, offset white_deselector
    jmp white_cell2
    black_cell2:
    mov shape_to_draw, offset black_deselector
    white_cell2:
    
    mov ax,s2_col
    mov col,ax
    mov ax,s2_row
    mov row,ax
    call draw_cell

     mov ax,s1_row
    cmp ax,s2_row
    jne deselect2_chOv
    mov ax,s1_col
    cmp ax,s2_col
    jne deselect2_chOv
       ;both selectors overlapped, so we draw the other selector since we just erased it
    call draw_selector1
    jmp no_overlapping2

    deselect2_chOv:  ;checking if there is overlapping between the selector and white highlighted cells and if so, draw the highlight again
    mov si,offset selectorMap
    mov ax,s2_row
    mov cx, s2_col
    mov dx,8d
    mul dl
    add ax,cx
    add si,AX
    mov al,01h
    cmp [si],al
     mov bx,s2_row
     mov valid_row,bl
    mov valid_col,cl
    jne deselect2_chOv2
    call draw_black_valid
    jmp no_overlapping2

    deselect2_chOv2:        ;checking if there is overlapping between the selector and black highlighted cells and if so, draw the highlight again
    mov al,10h
    cmp [si],al
    jne overlpValid2
    call draw_white_valid
    jmp no_overlapping2

    overlpValid2:   ;checking if there is overlapping between the selector and white&black highlighted cells and if so, draw the highlight again
    mov al,11h
    cmp [si],al
    jne no_overlapping2
    call draw_white_valid
    call draw_black_valid

    no_overlapping2:
    pop ax
    ret
deselect2 endp


deselect_valid2 proc        ; removes the highlight valid cell
   push ax

    cmp s2_color,0
    je black_cell22
    mov shape_to_draw, offset white_deselector
    jmp white_cell22
    black_cell22:
    mov shape_to_draw, offset black_deselector
    white_cell22:
    
    mov ax,s2_col
    mov col,ax
    mov ax,s2_row
    mov row,ax
    call draw_cell

   
    mov ax,s1_row
    cmp ax,s2_row
    jne no_overlapping22
    mov ax,s1_col
    cmp ax,s2_col
    jne no_overlapping22

    ;both selectors overlapped, so we draw the other selector since we just erased it
    call draw_selector1

    no_overlapping22:
    pop ax
    ret
deselect_valid2 endp
;--------------------------------------------------------------------------------------------------------------------------
Select_W proc ;Select White piece to move it
    cmp from_col,8 ; check if First Q
    je Select_W_dummy_jmp
    jmp Select_W_dummy_free
     Select_W_dummy_jmp:jmp skip; Jump if First Q
      Select_W_dummy_free:  call isMarkW  ;checks if this a valid cell to move to
        mov cl,1h
        cmp marked,cl
        je Highlighted
        mov ax,8      ; invalid move , undo the press
        mov from_col,ax
        mov from_row,ax
        call unmarkAllW   ; removes all the highlighted valid cells 
        ret
    Highlighted:   
   ; mov cursor
 
     mov ah,2
     mov dx,1819h
     int 10h 
     mov ah, 9
    mov dx,offset clean_threat
    int 21h
    call Change_W_place  ;move  White piece
      cmp EndGame,0Ah
   je nothreat
    call check_wking_threat
    mov cl,1
    cmp W_threat,1
    jne try_black_threat_
       ;mov cursor
     mov ah,2
     mov dx,1819h
     int 10h 
     mov ah, 9
    mov dx,offset W_threat_MSG
    int 21h
    mov W_threat,0
     try_black_threat_:
      call check_bking_threat
    mov cl,1
    cmp B_threat,1
    jne nothreat
        ; mov cursor
     mov ah,2
     mov dx,1819h
     int 10h 
     mov ah, 9
    mov dx,offset B_threat_MSG
    int 21h
    mov B_threat,0
    ;updating the opponent's drawn valid cells (if exist) after my move
    nothreat:
     mov cx,8
    cmp from_col_,cx
    je returnn
    mov al,piece_type
    push AX
    mov dl,Bpiece_type
    mov piece_type,dl
    call unmarkAllB
    call draw_valids
    pop ax
    mov piece_type,al
    returnn: ret
    skip:   ; if you click first Q
    PUSH_ALL
    ;Get First Q  coordinates 
    mov ax,s1_col
    mov from_col,ax
    mov ax,s1_row
    mov from_row,ax
    mov ax,0
    mov al,s1_color
    mov from_color,ax
;Check freezing
    cmp WFT,0
    je SkipFreezing2
  lea bx,LastMoveTime
  mov ax,from_row
  mov dl,8
  mul dl
  add ax,from_col
  add bx,ax
  mov al,[bx]
  cmp al,0
  jne Yarab
  ;-----
  SkipFreezing2:
    call check_W_piece
    cmp wFound,1  ; Check if you select one of your pieces
    je CheckEnd  
    Yarab:
    ;Return From row and col to their init val
    mov ax,8
    mov from_col,ax
    mov from_row,ax
    jmp fin
    CheckEnd:
    call draw_valids  ;hightlighting the valid cells from that piece
    fin: mov wFound,0
    POP_ALL
    ret
Select_W endp


draw_valids proc  ; switch case for the piece code --> invoking the right function to draw its valid moves
push_all
cmp piece_type,22h
    jne sec_knight
mov al, piece_type
mov  Wpiece_type,al
    call knight_draw_valid
    
    jmp exx
    sec_knight: cmp piece_type,32h
    jne bKnights 
mov al, piece_type
mov  Wpiece_type,al
    call knight_draw_valid
    
    jmp exx
    bKnights:
    cmp piece_type,02h
    jne sec_bknight
    mov al, piece_type
mov  Bpiece_type,al
    call Bknight_draw_valid
    
    jmp exx
    sec_bknight: 
    cmp piece_type,12h
    jne pawns
    mov al, piece_type
mov  Bpiece_type,al
    call Bknight_draw_valid
    
    jmp exx
    pawns: 
    mov al,piece_type
    mov ah,0
    mov dl,10h
    mov dh,0
    div dl
    cmp al,5d
    jne bPawnss
mov al, piece_type
mov  Wpiece_type,al
    call pawn_draw_valid
    
    jmp exx
    bPawnss:
    cmp al,4d
    jne bishops
  mov al, piece_type
mov  Bpiece_type,al
    call Bpawn_draw_valid
    
    jmp exx
  bishops:
  cmp piece_type,23h
  jne secBishop
  mov si, offset bishopOffset
mov al, piece_type
mov  Wpiece_type,al
  call draw_continous_valid
  
  jmp exx 
  secBishop:
    cmp piece_type,33h
    jne BBishops
    mov si, offset bishopOffset
mov al, piece_type
mov  Wpiece_type,al
  call draw_continous_valid
  
  jmp exx
  BBishops:
    cmp piece_type,03h
  jne secBBishop
  mov si, offset bishopOffset
  mov al, piece_type
mov  Bpiece_type,al
  call Bdraw_continous_valid
  
  jmp exx 
  SecBBishop:
   cmp piece_type,13h
    jne rooks
    mov si, offset bishopOffset
    mov al, piece_type
mov  Bpiece_type,al
  call Bdraw_continous_valid
  
  jmp exx
  rooks:
  cmp piece_type,31h
  jne secRook
  mov si, offset RookOffset
mov al, piece_type
mov  Wpiece_type,al
  call draw_continous_valid
  
  jmp exx 
  secRook:
    cmp piece_type,21h
    jne bRooks
    mov si, offset RookOffset
mov al, piece_type
mov  Wpiece_type,al
  call draw_continous_valid
  
jmp exx
bRooks:
cmp piece_type,01h
  jne secBRook
  mov si, offset RookOffset
  mov al, piece_type
mov  Bpiece_type,al
  call Bdraw_continous_valid
  
  jmp exx 
  secBRook:
  cmp piece_type,11h
    jne queen
    mov si, offset RookOffset
    mov al, piece_type
mov  Bpiece_type,al
  call Bdraw_continous_valid
  
jmp exx
  queen:
   cmp piece_type,1Bh
    jne bQueenk
mov al, piece_type
mov  Wpiece_type,al
  call queen_draw_valid
  
  jmp exx
  bQueenk:
  cmp piece_type,0Bh
    jne king
mov al, piece_type
mov  Bpiece_type,al
  call Bqueen_draw_valid
  
  jmp exx
  king:
  cmp piece_type,1Ah   ;01,12
    jne bKingk
mov al, piece_type
mov  Wpiece_type,al
  call king_draw_valid
  
  jmp exx
  bKingk:
   cmp piece_type,0Ah   ;01,12
    jne exx
mov al, piece_type
mov  Bpiece_type,al
  call Bking_draw_valid
  
    exx:


pop_all
ret
draw_valids endp
;==================================================================
move_black proc
push_all
call get_B_piece
mov cl,0Ah
 cmp Bpiece_type,cl
 jne notKing_r
 mov ax,from_col_
 mov Bking_col,Al
  mov ax,from_row_
 mov Bking_row,Al
 ;Get the destination cell you want to move the piece to
    notKing_r:
  ;------------------------------------------Bonus promotion
  mov cl,40h
  cmp Bpiece_type,cl
  jl notPawn___r
    mov cl,47h
  cmp Bpiece_type,cl
  jg notPawn___r
      mov cx,7
      cmp to_row_,cx
      jne notPawn___r
  mov Bpiece_type,0Bh
  mov ax,offset bQueen
  mov bPiece,ax
    notPawn___r: 
    push cx
      lea bx,boardMap
      mov ax,to_row_
      mov cl,8
      mul cl
      add ax,to_col_
      add bx,ax
      mov al,[bx]
      ;-------------Check if King Killed
      cmp al,1Ah
      Jne notEndGame_r
      mov EndGame,1Ah
      call PrintWinner

      notEndGame_r:
      ;------------check if you eat black peice
      cmp al,00h
      je no_White_eat_r
      mov KilledWhite,al
      call PrintWhiteKilled
      no_White_eat_r:
    pop cx
    ;----------------


    lea bx,boardMap

    mov ax,from_row_
     mov cl,8
     mul cl
     add ax,from_col_
     add bx,ax
    mov dl,[bx]
    mov cx,00h
    mov [bx],cl
    lea bx,boardMap
    mov ax,to_row_
     mov cl,8
     mul cl
     add ax,to_col_
     add bx,ax
     mov al,Bpiece_type
      mov[bx],al
    ; get source cell color if row + col==odd --> cell is black
    mov ax,from_col_
    add ax,from_row_
    and ax,0001h
    cmp ax,0000h
    jne b__cell__b
    call draw_W_from_cell_
    jmp con_22
    b__cell__b:
    call draw_B_from_cell_
    con_22:
        ; get distinion cell color if row + col==odd --> cell is black
    mov ax,to_col_
    add ax,to_row_
    and ax,0001h
    cmp ax,0000h
    jne b___cell__
    call draw_W_to_cell_
    jmp coon__
    b___cell__:
    call draw_B_to_cell_
    coon__:
    mov cx ,to_col_
    cmp cx, from_col
    jne Skip___20
    mov cx ,to_row_
    cmp cx, from_row
    jne Skip___20
    call unmarkAllW
    mov cx,8
    mov from_col,cx
    mov from_row,cx
    Skip___20:
    mov ax,bPiece
    mov shape_to_draw,ax
    mov ax,8
    mov from_col_,ax
    mov from_row_,ax
    POP_ALL
    call move_piece_
    call draw_selector2

    cmp EndGame,1Ah
    jne sskkiipp_
ret
sskkiipp_:
    push_all
          mov ah,2
       mov dx,1819h
       int 10h 
       mov ah, 9
      mov dx,offset clean_threat
       int 21h
        call check_wking_threat
    mov cl,1
    cmp W_threat,1
    jne try_black_threat_r
        ; mov cursor
     mov ah,2
     mov dx,1819h
     int 10h 
     mov ah, 9
    mov dx,offset W_threat_MSG
    int 21h
    mov W_threat,0
    try_black_threat_r:
      call check_bking_threat
    mov cl,1
    cmp B_threat,1
    jne nothreat_r
        ; mov cursor
     mov ah,2
     mov dx,1819h
     int 10h 
     mov ah, 9
    mov dx,offset B_threat_MSG
    int 21h
    mov B_threat,0
    ;updating the opponent's drawn valid cells (if exist) after my move
    nothreat_r:
        mov cx,8
        cmp from_col,cx
        je move_fin
        mov al,piece_type
        push AX
        mov dl,Wpiece_type
        mov piece_type,dl
        call unmarkAllW
        call draw_valids
        pop ax
        mov piece_type,al
        move_fin:

    pop_all
ret
move_black endp
;-------------------------------------------------
get_B_piece proc 
     PUSH_ALL
     lea bx,boardMap
     mov ax,from_row_
     mov cl,8
     mul cl
     add ax,from_col_
     add bx,ax
     mov al,[bx]
     mov bPiece,offset bKnight
     cmp al,02h
     je found_b_ 
     cmp al,12h
     je found_b_
    mov bPiece,offset bRook
     cmp al,11h
     je found_b_ 
     cmp al,01h
     je found_b_  
     mov bPiece,offset bBishop
     cmp al,13h
     je found_b_ 
     cmp al,03h
     je found_b_
     mov bPiece,offset bPawn
     cmp al,40h
     je found_b_ 
     cmp al,41h
     je found_b_ 
     cmp al,42h
     je found_b_ 
     cmp al,43h
     je found_b_ 
     cmp al,44h
     je found_b_ 
     cmp al,45h
     je found_b_ 
     cmp al,46h
     je found_b_ 
     cmp al,47h
     je found_b_ 
     mov bPiece,offset bKing
     cmp al,0Ah
     je found_b_ 
     mov bPiece,offset bQueen
     cmp al,0Bh
     je found_b_
     jmp end_get
     found_b_:
          mov Bpiece_type,al
     end_get:
     POP_ALL
     ret
get_B_piece endp
;------------------------------------------------------
;==================================================================
move_white proc
push_all
call get_W_piece
mov cl,1Ah
 cmp Wpiece_type,cl
 jne notKing__r
 mov ax,from_col
 mov Wking_col,Al
  mov ax,from_row
 mov Wking_row,Al
 ;Get the destination cell you want to move the piece to
    notKing__r:
  ;------------------------------------------Bonus promotion
  mov cl,50h
  cmp Wpiece_type,cl
  jl notPawn____r
    mov cl,57h
  cmp Wpiece_type,cl
  jg notPawn____r
      mov cx,0
      cmp to_row,cx
      jne notPawn____r
  mov Wpiece_type,1Bh
  mov ax,offset wQueen
  mov wPiece,ax
    notPawn____r: 
    push cx
      lea bx,boardMap
      mov ax,to_row
      mov cl,8
      mul cl
      add ax,to_col
      add bx,ax
      mov al,[bx]
      ;-------------Check if King Killed
      cmp al,0Ah
      Jne notEndGame_rr
      mov EndGame,0Ah
      call PrintWinner
      notEndGame_rr:
      ;------------check if you eat black peice
      cmp al,00h
      je no_Black_eat_r
      mov KilledBlack,al
      call PrintBlackKilled
      no_Black_eat_r:

    pop cx
    ;----------------


    lea bx,boardMap

    mov ax,from_row
     mov cl,8
     mul cl
     add ax,from_col
     add bx,ax
    mov dl,[bx]
    mov cx,00h
    mov [bx],cl
    lea bx,boardMap
    mov ax,to_row
     mov cl,8
     mul cl
     add ax,to_col
     add bx,ax
     mov al,Wpiece_type
      mov[bx],al
    ; get source cell color if row + col==odd --> cell is black
    mov ax,from_col
    add ax,from_row
    and ax,0001h
    cmp ax,0000h
    jne b__cell__
    call draw_W_from_cell
    jmp con_22_
    b__cell__:
    call draw_B_from_cell
    con_22_:
        ; get distinion cell color if row + col==odd --> cell is black
    mov ax,to_col
    add ax,to_row
    and ax,0001h
    cmp ax,0000h
    jne b___cell__r
    call draw_W_to_cell
    jmp coon__r
    b___cell__r:
    call draw_B_to_cell
    coon__r:
    mov cx ,to_col
    cmp cx, from_col_
    jne Skip___20_
    mov cx ,to_row
    cmp cx, from_row_
    jne Skip___20_
    call unmarkAllB
    mov cx,8
    mov from_col_,cx
    mov from_row_,cx
    Skip___20_:
    mov ax,wPiece
    mov shape_to_draw,ax
    mov ax,8
    mov from_col,ax
    mov from_row,ax
    POP_ALL
    call move_piece
    call draw_selector1

    cmp EndGame,0Ah
    jne sskkiipp
ret
sskkiipp:

    push_all
          mov ah,2
       mov dx,1819h
       int 10h 
       mov ah, 9
      mov dx,offset clean_threat
       int 21h
        call check_wking_threat
    mov cl,1
    cmp W_threat,1
    jne try_black_threat_r_
        ; mov cursor
     mov ah,2
     mov dx,1819h
     int 10h 
     mov ah, 9
    mov dx,offset W_threat_MSG
    int 21h
    mov W_threat,0
    try_black_threat_r_:
      call check_bking_threat
    mov cl,1
    cmp B_threat,1
    jne nothreat_r_
        ; mov cursor
     mov ah,2
     mov dx,1819h
     int 10h 
     mov ah, 9
    mov dx,offset B_threat_MSG
    int 21h
    mov B_threat,0
    ;updating the opponent's drawn valid cells (if exist) after my move
    nothreat_r_:
        mov cx,8
        cmp from_col_,cx
        je move_fin_
        mov al,piece_type
        push AX
        mov dl,Bpiece_type
        mov piece_type,dl
        call unmarkAllB
        call draw_valids
        pop ax
        mov piece_type,al
        move_fin_:

    pop_all
ret
move_white endp
;-------------------------------------------------
get_W_piece proc 
     PUSH_ALL
     lea bx,boardMap
     mov ax,from_row
     mov cl,8
     mul cl
     add ax,from_col
     add bx,ax
     mov al,[bx]
    mov wPiece,offset wRook
     cmp al,31h
     je found_w_r 
     cmp al,21h
     je found_w_r 
          mov wPiece,offset wKnight
     cmp al,22h
     je found_w_r
     cmp al,32h
     je found_w_r
     mov wPiece,offset wBishop
     cmp al,23h
     je found_w_r 
     cmp al,33h
     je found_w_r
          mov wPiece,offset wPawn
     cmp al,50h
     je found_w_r 
     cmp al,51h
     je found_w_r 
     cmp al,52h
     je found_w_r 
     cmp al,53h
     je found_w_r 
     cmp al,54h
     je found_w_r 
     cmp al,55h
     je found_w_r 
     cmp al,56h
     je found_w_r 
     cmp al,57h
     je found_w_r 
     mov wPiece,offset wKing
     cmp al,1Ah
     je found_w_r 
     mov wPiece,offset wQueen
     cmp al,1Bh
     je found_w_r
     jmp end_get_
     found_w_r:
          mov Wpiece_type,al
     end_get_:
     POP_ALL
     ret
get_W_piece endp
;------------------------------------------------------
Select_B proc ;Select Black piece to move it
    cmp from_col_,8 ; check if First E
    je Select_B_dummy_jmp
    jmp Select_B_dummy_free
    
    Select_B_dummy_jmp:jmp skip_ ; Jump if First E
    Select_B_dummy_free: 
    call isMarkB ;checks if this a valid cell to move to
        mov cl,1h
        cmp marked,cl 
        je Select_B_highlighted
        mov ax,8 ; invalid move -> undo the q press 
        mov from_col_,ax
        mov from_row_,ax
        call unmarkAllB ; undo the highlight for valid cells
        ret

    ;updating the opponent's drawn valid cells (if exist) after my move
    Select_B_highlighted:  
      mov ah,2
       mov dx,1819h
       int 10h 
       mov ah, 9
      mov dx,offset clean_threat
       int 21h
        call Change_B_place   ;move  Black piece
              cmp EndGame,1Ah
          je nothreat_
        call check_wking_threat
    mov cl,1
    cmp W_threat,1
    jne try_black_threat
        ; mov cursor
     mov ah,2
     mov dx,1819h
     int 10h 
     mov ah, 9
    mov dx,offset W_threat_MSG
    int 21h
    mov W_threat,0
    try_black_threat:
      call check_bking_threat
    mov cl,1
    cmp B_threat,1
    jne nothreat_
        ; mov cursor
     mov ah,2
     mov dx,1819h
     int 10h 
     mov ah, 9
    mov dx,offset B_threat_MSG
    int 21h
    mov B_threat,0
    ;updating the opponent's drawn valid cells (if exist) after my move
    nothreat_:
        mov cx,8
        cmp from_col,cx
        je dummy
        jmp nodummy
        dummy: jmp returnn
        nodummy: mov al,piece_type
        push AX
        mov dl,Wpiece_type
        mov piece_type,dl
        call unmarkAllW
        call draw_valids
        pop ax
        mov piece_type,al
        ret

    skip_:  ; if you click first Q
    PUSH_ALL
    ;Get First select  coordinates
    mov ax,s2_col
    mov from_col_,ax
    mov ax,s2_row
    mov from_row_,ax
    mov ax,0
    mov al,s2_color
    mov from_color_,ax

;Check freezing
    cmp BFT,0
    je SkipFreezing2_
  lea bx,LastMoveTime
  mov ax,from_row_
  mov dl,8
  mul dl
  add ax,from_col_
  add bx,ax
  mov al,[bx]
  cmp al,0
  jg Yarab_
  ;-----
  SkipFreezing2_:

    call check_B_piece
    cmp bFound,1  ; Check if you select one of your pieces
    je CheckEnd_
    Yarab_:
    ;Return From_ row and col to their init val
    mov ax,8
    mov from_col_,ax
    mov from_row_,ax
    jmp ffx
    CheckEnd_:
    call draw_valids  ;hightlighting the valid cells from that piece
    ffx:
    mov bFound,0
    POP_ALL
    ret
Select_B endp

;--------------------------------
Change_W_place proc 
push ax
 call unmarkAllW 
 mov cl,1Ah
 cmp Wpiece_type,cl
 jne notKing
 mov ax,s1_col
 mov Wking_col,Al
  mov ax,s1_row
 mov Wking_row,Al
 ;Get the destination cell you want to move the piece to
   notKing: 
   mov ax,s1_col
    mov to_col,ax
    mov ax,s1_row
    mov to_row,ax
    mov ax,0
    mov al,s1_color
    mov to_color,ax
    ;------------------------------------------Bonus promotion
  mov cl,50h
  cmp Wpiece_type,cl
  jl notPawn__
    mov cl,57h
  cmp Wpiece_type,cl
  jg notPawn__
      mov cx,0
      cmp to_row,cx
      jne notPawn__
  mov Wpiece_type,1Bh
  mov ax,offset wQueen
  mov wPiece,ax

    notPawn__: 
    ;---------Bonus frezzing
    push cx
    ; get index of destination cell in array to freeze it after moving 
      lea bx,boardMap
      mov ax,to_row
      mov cl,8
      mul cl
      add ax,to_col
      add bx,ax
      mov al,[bx]
      cmp al,0AAh
      Jne no_PowerUp
      sub WFT,01H
      no_PowerUp:
      cmp al,0Ah
      Jne notEndGame
      mov EndGame,0Ah
      call PrintWinner
      notEndGame:
      ;------------check if you eat black peice
      cmp al,00h
      je no_Black_eat
      mov KilledBlack,al
      call PrintBlackKilled
      no_Black_eat:
    pop cx
    ;----------------
    ; get source cell color if row + col==odd --> cell is black
    mov ax,from_col
    add ax,from_row
    and ax,0001h
    cmp ax,0000h
    jne b__cell
    call draw_W_from_cell
    jmp con
    b__cell:
    call draw_B_from_cell
    con:
        ; get destination cell color if row + col==odd --> cell is black
    mov ax,to_col
    add ax,to_row
    and ax,0001h
    cmp ax,0000h
    jne b___cell
    call draw_W_to_cell
    jmp coon
    b___cell:
    call draw_B_to_cell
    coon:

    mov ax,to_col
    mov s1_col,ax
    mov ax,to_row
    mov s1_row,ax

    pop ax
        PUSH_ALL
        ;update boardMap
    lea bx,boardMap
    mov ax,from_row
    mov cl,8
    mul cl
    add ax,from_col
        mov from_cell,al
    add bx,ax
    mov al,[bx]
    mov cx,00h
    mov [bx],cl
    push ax
    mov bx , offset boardMap
    mov ax,to_row
    mov cx,8
    mul cx
    add ax,to_col
    mov to_cell,al


        cmp player_mode,1
    jne no_send_white_
    call send_movement
    no_send_white_:
    add bx,ax
    pop ax
    mov al,Wpiece_type
    mov [bx],al
    mov cx ,to_col
    cmp cx, from_col_
    jne Skip___
    mov cx ,to_row
    cmp cx, from_row_
    jne Skip___
    call unmarkAllB
    mov cx,8
    mov from_col_,cx
    mov from_row_,cx
    Skip___:
    mov ax,wPiece
    mov shape_to_draw,ax
    draw_:
    ;
    ;
    cmp WFT,0
    je SkipFreezing1
    call FreezingW
    SkipFreezing1:
    ;
    ;
        ;Return From row and col to their init val

    mov ax,8
    mov from_col,ax
    mov from_row,ax
    POP_ALL
    call move_piece
    call draw_selector2
    call draw_selector1
    ret
Change_W_place endp
;-----------------------------------------------
Change_B_place proc 
push ax
call unmarkAllB
mov cl,0Ah
 cmp Bpiece_type,cl
 jne notKing_
 mov ax,s2_col
 mov Bking_col,Al
  mov ax,s2_row
 mov Bking_row,Al
 ;Get the destination cell you want to move the piece to
    notKing_:
    mov ax,s2_col
    mov to_col_,ax
    mov ax,s2_row
    mov to_row_,ax
    mov ax,0
    mov al,s2_color
    mov to_color_,ax
        ;------------------------------------------Bonus promotion
  mov cl,40h
  cmp Bpiece_type,cl
  jl notPawn___
    mov cl,47h
  cmp Bpiece_type,cl
  jg notPawn___
      mov cx,7
      cmp to_row_,cx
      jne notPawn___
  mov Bpiece_type,0Bh
  mov ax,offset bQueen
  mov bPiece,ax

    notPawn___: 
        ;---------Bonus freezing
    push cx
      ; get index of destination cell in array to freeze it after moving 
      lea bx,boardMap
      mov ax,to_row_
      mov cl,8
      mul cl
      add ax,to_col_
      add bx,ax
      mov al,[bx]
      cmp al,0AAh
      Jne no_PowerUp_
      sub BFT,01H
      no_PowerUp_:
      ;-------------Check if King Killed
      cmp al,1Ah
      Jne notEndGame_
      mov EndGame,1Ah
      call PrintWinner
      notEndGame_:
      ;------------check if you eat black peice
      cmp al,00h
      je no_White_eat
      mov KilledWhite,al
      call PrintWhiteKilled
      no_White_eat:
    pop cx
    ;----------------
        ; get source cell color if row + col==odd --> cell is black
    mov ax,from_col_
    add ax,from_row_
    and ax,0001h
    cmp ax,0000h
    jne b__cell_
    call draw_W_from_cell_
    jmp con_
    b__cell_:
    call draw_B_from_cell_
    con_:
        ; get distinion cell color if row + col==odd --> cell is black
    mov ax,to_col_
    add ax,to_row_
    and ax,0001h
    cmp ax,0000h
    jne b___cell_
    call draw_W_to_cell_
    jmp coon_
    b___cell_:
    call draw_B_to_cell_
    coon_:
    mov ax,to_row_
    mov s2_row,ax
    mov ax,to_col_
    mov s2_col,ax
    pop ax
        PUSH_ALL
        ;update boardMap
    lea bx,boardMap
    mov ax,from_row_
    mov cl,8
    mul cl
    add ax,from_col_
    mov from_cell,al
    add bx,ax
    mov al,[bx]
    mov cx,00h
    mov [bx],cl
    push ax
    mov bx , offset boardMap
    mov ax,to_row_
    mov cx,8
    mul cx
    add ax,to_col_
    mov to_cell,al

    cmp player_mode,2
    jne no_send_black_
    call send_movement
    no_send_black_:

    add bx,ax
    pop ax
    mov al,Bpiece_type
    mov [bx],al
    mov cx ,to_col_
    cmp cx, from_col
    jne Skip___2
    mov cx ,to_row_
    cmp cx, from_row
    jne Skip___2
    call unmarkAllW
    mov cx,8
    mov from_col,cx
    mov from_row,cx
    Skip___2:
    mov ax,bPiece
    mov shape_to_draw,ax
    draw__:
    ;
    ;
    cmp BFT,0
    je SkipFreezing1_
    call FreezingB
    SkipFreezing1_:
    ;Return From_ row and col to their init val
    mov ax,8
    mov from_col_,ax
    mov from_row_,ax
    POP_ALL
    call move_piece_
    call draw_selector1
    call draw_selector2
    ret
Change_B_place endp
;------------------------------------------------------------------------------------------------------
; Helper functions for validating cells


isMarkW proc ;checks if a cell highlighted valid for white piece (used to validate the move)
push_all
mov ax,s1_row
mov bx,s1_col
mov dx,8d
mul dx
add ax,bx
mov bx,ax
mov si,offset selectorMap
mov cl,10h
add si,bx
cmp [si],cl
jne npe
yess: mov al,1
mov marked,al
jmp ex
npe:
mov cl,11h  ; checks if there is overlapping between valid cells highlighted 
cmp [si],cl
je yess
mov al,0 
mov marked,al

ex: pop_all

ret
isMarkW endp
;-------------------------------
isMarkB proc  ;checks if a cell highlighted valid for black piece (used to validate the move)
push_all
mov ax,s2_row
mov bx,s2_col
mov dx,8d
mul dl
add ax,bx
mov bx,ax
mov si,offset selectorMap
mov cl,01h
add si,bx
cmp [si],cl
jne isMarkB_npe
yea: mov al,1
mov marked,al
jmp isMarkB_ex
isMarkB_npe:
mov cl,11h    ; checks if there is overlapping between valid cells highlighted 
cmp [si],cl 
je yea
mov al,0 
mov marked,al

isMarkB_ex: pop_all

ret
isMarkB endp

markthisCellW proc ; mark a cell with white mark in selectorMap
push_all
mov si,offset selectorMap
mov ah,0
mov dh,0
mov dl,8
mov al,valid_row
mul dl
add al,valid_col
mov bh,0
mov bl,al
mov cl,01h
cmp [si+bx],cl
jne singleMark
mov cl,11h        ; checks if there is already highlighting for the opponent's piece
mov [si+bx],cl
jmp outtt
singleMark: mov cl,10h
mov [si+bx],cl
outtt: pop_all
ret
markthisCellW endp

markthisCellB proc ; mark a cell with black mark in selectorMap
push_all
mov si,offset selectorMap
mov ah,0
mov dh,0
mov dl,8
mov al,valid_row
mul dl
add al,valid_col
mov bh,0
mov bl,al
mov cl,10h
cmp [si+bx],cl
jne singleMark1
mov cl,11h          ; checks if there is already highlighting for the opponent's piece
mov [si+bx],cl
jmp outtt2
singleMark1:
mov cl,01h
mov [si+bx],cl
outtt2: 
pop_all
ret
markthisCellB endp

unmarkAllW proc  ; unmark all cells after second q pressed
push_all
mov al,s2_color
mov ah,0
push  ax
mov ax,s2_col
push AX
mov ax,s2_row
push ax
mov s2_color,0ffh
mov cx,64d
mov si,offset selectorMap
mov al,0 ;row
mov ah,0
mov dl,0;col
mov dh,0
init:
mov bl,10h
cmp [si],bl
jne overlp
mov bl,00
mov [si],bl
mov s2_row,ax
mov s2_col,dx
call deselect_valid2
jmp conti
overlp:
mov bl,11h    ;checking if thereis overlapping , if so, -> draw the other highlight
cmp [si],bl
jne conti
mov bl,01h
mov [si],bl
mov s2_row,ax
mov s2_col,dx
call deselect_valid2
mov valid_col,dl
mov valid_row,al
call draw_black_valid
conti:
cmp dx,7        ; continue the loop and checks if the row is checks --> go to the next row
jne nowrap
mov dx,0
inc ax
jmp unmarkAllW_con
nowrap:
not s2_color
inc dx

unmarkAllW_con: inc si
dec cx
jnz init

pop ax 
mov s2_row,ax
pop ax
mov s2_col,ax
pop AX
mov s2_color,al
call draw_selector2
pop_all
ret
unmarkAllW endp

unmarkAllB proc  ; unmark all cells after second q pressed
push_all
mov al,s1_color
mov ah,0
push  ax
mov ax,s1_col
push AX
mov ax,s1_row
push ax
mov s1_color,0ffh
mov cx,64d
mov si,offset selectorMap
mov al,0 ;row
mov ah,0
mov dl,0 ;col
mov dh,0
init2:
mov bl,01h
cmp [si],bl
jne overlp2
mov bl,00
mov [si],bl
mov s1_row,ax
mov s1_col,dx
call deselect_valid1
jmp conti2
overlp2:
mov bl,11h        ;checking if thereis overlapping , if so, -> draw the other highlight
cmp [si],bl
jne conti2
mov bl,10h
mov [si],bl
mov s1_row,ax
mov s1_col,dx
call deselect_valid1
mov valid_col,dl
mov valid_row,al
call draw_white_valid
conti2:
cmp dx,7
jne nowrap2         ; continue the loop and checks if the row is checks --> go to the next row
mov dx,0
inc ax
jmp cn2
nowrap2:
not s1_color
inc dx

cn2: inc si
dec cx
jnz init2

pop ax 
mov s1_row,ax
pop ax
mov s1_col,ax
pop AX
mov s1_color,al
call draw_selector1
pop_all
ret
unmarkAllB endp

is_W_here proc ; checks if there is a white piece in a cell
push_all
mov ax, from_color
push ax
mov ax,wPiece
push ax
mov ax,wFound
push ax
mov ax,from_col
push ax
mov ax,from_row
push ax
mov bh,0
mov dh,0
mov from_col,bx
mov from_row,dx
call check_W_piece  ; checks and update piece_type if exists
cmp wFound,1    ; piece found
jne nope
mov valid,0
jmp cnn
nope: mov valid,1
cnn: pop ax
mov from_row,ax
pop ax
mov from_col,ax
pop ax
mov wFound,ax
pop ax
mov wPiece,ax
pop ax
mov from_color,ax
pop_all
ret
is_W_here endp

is_B_here proc ; checks if there is a white piece in a cell
push_all
mov ax, from_color_
push ax
mov ax,bPiece
push ax
mov ax,bFound
push ax
mov ax,from_col_
push ax
mov ax,from_row_
push ax
mov bh,0
mov dh,0
mov from_col_,bx
mov from_row_,dx
call check_B_piece       ; checks and update piece_type if exists
cmp bFound,1      ; piece found
jne nope22
mov valid,0
jmp conn2
nope22: mov valid,1
conn2: pop ax
mov from_row_,ax
pop ax
mov from_col_,ax
pop ax
mov bFound,ax
pop ax
mov bPiece,ax
pop ax
mov from_color_,ax
pop_all
ret
is_B_here endp

isStarhere proc    ; checks if there is power up in a cell
push_all
mov si, offset boardMap
mov ax,dx
mov dl,8
mul dl
add ax,bx
add si,ax
mov bl ,0AAh
cmp [si],bl
jne no123
mov valid,1
jmp getout
no123:
mov valid,0
getout:pop_all
ret
isStarhere endp


is_Bbishop proc 
push_all
mov valid,0
cmp piece_type,03h
jne secBlackBishop
mov valid,1
jmp exitbishop
secBlackBishop:
cmp piece_type,13h
jne exitbishop
mov valid,1
jmp exitbishop
exitbishop:
pop_all
ret
is_Bbishop endp

is_Brook proc 
push_all
mov valid,0
cmp piece_type,01h
jne secBlackrook
mov valid,1
jmp exitrook
secBlackrook:
cmp piece_type,11h
jne exitrook
mov valid,1
jmp exitrook
exitrook:
pop_all
ret
is_Brook endp

is_Bknight proc 
push_all
mov valid,0
cmp piece_type,02h
jne secBlackknight
mov valid,1
jmp exitknight
secBlackknight:
cmp piece_type,12h
jne exitknight
mov valid,1
exitknight:
pop_all
ret
is_Bknight endp

is_Bking proc 
push_all
mov valid,0
cmp piece_type,0Ah
jne nobking
mov valid,1
nobking:
pop_all
ret
is_Bking endp

is_Bqueen proc
push_all
mov valid,0
cmp piece_type,0Bh
jne nobqueen
mov valid,1
nobqueen:
pop_all
ret
is_Bqueen endp

is_Bpawn proc 
push_all
mov ah,0
mov al,piece_type
mov dl,10h
div dl
cmp al,4
jne notPawn
mov valid,1
jmp exitF
notPawn:
mov valid,0
exitF:
pop_all
ret
is_Bpawn endp

isIn proc ; checks if a cell is within board boundaries
cmp bl,7
jg no
cmp bl,0
jl no
cmp dl,7
jg no
cmp dl,0
jl no
mov valid,1
jmp exit
no:
mov valid,0
exit:
ret
isIn endp
;--------------------------------------------------------------------------------------------------------------------------------


is_Wbishop proc 
push_all
mov valid,0
cmp piece_type,23h
jne secBlackBishop_
mov valid,1
jmp exitbishop_
secBlackBishop_:
cmp piece_type,33h
jne exitbishop_
mov valid,1
jmp exitbishop_
exitbishop_:
pop_all
ret
is_Wbishop endp

is_Wrook proc 
push_all
mov valid,0
cmp piece_type,21h
jne secBlackrook_
mov valid,1
jmp exitrook_
secBlackrook_:
cmp piece_type,31h
jne exitrook_
mov valid,1
jmp exitrook_
exitrook_:
pop_all
ret
is_Wrook endp

is_Wknight proc 
push_all
mov valid,0
cmp piece_type,22h
jne secWhiteknight_
mov valid,1
jmp exitknight_
secWhiteknight_:
cmp piece_type,32h
jne exitknight_
mov valid,1
exitknight_:
pop_all
ret
is_Wknight endp

is_Wking proc 
push_all
mov valid,0
cmp piece_type,1Ah
jne nobking_
mov valid,1
nobking_:
pop_all
ret
is_Wking endp

is_Wqueen proc
push_all
mov valid,0
cmp piece_type,1Bh
jne nobqueen_
mov valid,1
nobqueen_:
pop_all
ret
is_Wqueen endp

is_Wpawn proc 
push_all
mov ah,0
mov al,piece_type
mov dl,10h
div dl
cmp al,5
jne notPawn_
mov valid,1
jmp exitF_
notPawn_:
mov valid,0
exitF_:
pop_all
ret
is_Wpawn endp

;------------------------------------------------------------------------------------------------------
knight_draw_valid proc   ; loops on the knight_offset array and validate each move, if valid--> draw highlighting to the cell
push_all
mov cx,8d
mov di, offset knightOffset
cont: 
mov bx,from_col
mov dx,from_row
mov al,[di]
add bl,al
mov al,[di+1]
add dl,al
add di,2
call isIn
cmp valid,1
jne not_valid
call is_W_here      ; checks if there is a piece of the same type , if not continue, if there is do not draw highlight
cmp valid,1
jne not_valid
mov valid_col,bl
mov valid_row,dl
call draw_white_valid
call markthisCellW
not_valid:
dec cx
jnz cont
pop_all
ret
knight_draw_valid endp

Bknight_draw_valid proc        ; loops on the knight_offset array and validate each move, if valid--> draw highlighting to the cell
push_all
mov cx,8d
mov di, offset knightOffset

cont33: 
mov bx,from_col_
mov dx,from_row_
mov al,[di]
add bl,al
mov al,[di+1]
add dl,al
add di,2
call isIn
cmp valid,1
jne not_valid33
call is_B_here        ; checks if there is a piece of the same type , if not continue, if there is do not draw highlight
cmp valid,1
jne not_valid33
mov valid_col,bl
mov valid_row,dl
call draw_black_valid
call markthisCellB
not_valid33:
 dec cx
jnz cont33

pop_all
ret

Bknight_draw_valid endp


;------------------------------------------------------------------------------------------------------

pawn_draw_valid proc   ; it validate the moves of a pawn
push_all
mov cx,bFound
push cx
mov cx,bPiece
push cx
mov bx,from_col
mov ax,from_row
dec ax
mov dx,ax
call isIn  ; checks if it is inside the boundaries of the board
cmp valid,1
jne dummyl 
jmp dummyfree   ; dummy label for making a long jump
dummyl: jmp outt
dummyfree: push AX
push bx
mov dx,8d
mul dl
add ax,bx
mov si,offset boardMap
add si,ax
mov cx,00
pop bx
pop ax
cmp [si],cl     ; checks if there is no piece in front of the pawn, if there is -> dont continue and move to the diagonals if there is enemy pieces
je ye1s
mov cl,0AAh
cmp [si],cl
jne nxtvald
ye1s: mov valid_row,al
mov valid_col,bl
call draw_white_valid
call markthisCellW
mov cx,6
cmp from_row,cx     ; checks if it is the first move for the pawn, he could move two step forward
jne nxtvald
sub si,8
mov cx,00
cmp [si],cl
je ye2s
mov cl,0AAh
cmp [si],cl
jne nxtvald
ye2s:
dec ax
mov valid_row,al
mov valid_col,bl
call draw_white_valid
call markthisCellW
inc ax

nxtvald:
inc bx
mov dx,ax
call isIn ;checks if the diagonals inside boundaries
cmp valid,1
jne noo

mov cx,from_col_
push cx
mov cx, from_row_
push cx
mov from_row_,ax
mov from_col_,bx
call check_B_piece  ; checks if there is enemy in the diagonals to be eaten, if thereis highlight
pop cx
mov from_row_,cx
pop cx
mov from_col_,cx
mov cx,0
cmp bFound,cx
je noo
mov valid_col,bl
mov valid_row,al
call draw_white_valid
call markthisCellW
noo:              ;doing the same checks for the other diagonal
sub bx,2
mov dx,ax
call isIn
cmp valid,1
jne outt
mov cx,from_col_
push cx
mov cx, from_row_
push cx
mov from_row_,ax
mov from_col_,bx
call check_B_piece
pop cx
mov from_row_,cx
pop cx
mov from_col_,cx
mov cx,0
cmp bFound,cx
je outt
mov valid_col,bl
mov valid_row,dl
call draw_white_valid
call markthisCellW
jmp outt

outt:
pop cx
mov bPiece,cx
pop cx
mov bFound,cx
pop_all
ret
pawn_draw_valid endp


;-------------------------------------------------------------------------------

Bpawn_draw_valid proc      ; it validate the moves of a pawn
push_all
mov cx,wFound
push cx
mov cx,wPiece
push cx
mov bx,from_col_
mov ax,from_row_
inc ax ; check if there is a piece direct in front of it 
mov dx,ax
call isIn
cmp valid,1
jne dummy_
jmp dummyfree_
dummy_: jmp outt5     ; dummy label for making a long jump
dummyfree_: 
push AX
push bx
mov dx,8d
mul dl
add ax,bx
mov si,offset boardMap
add si,ax
mov cx,00
pop bx
pop ax
cmp [si],cl      ; checks if there is no piece in front of the pawn, if there is -> dont continue and move to the diagonals if there is enemy pieces
je ye3s
mov cl,0AAh       ; checks if there is power up to highlight it also
cmp [si],cl
jne nxtvald5
ye3s:
mov valid_row,al
mov valid_col,bl
call draw_black_valid
call markthisCellB
mov cx,1      ; checks if it is the first move for the pawn, he could move two step forward
cmp from_row_,cx
jne nxtvald5
add si,8
mov cx,00       
cmp [si],cl
je ye4s
mov cl,0AAh       ; checks if there is power up to highlight it also
cmp [si],cl
jne nxtvald5
ye4s:
inc ax
mov valid_row,al
mov valid_col,bl
call draw_black_valid
call markthisCellB
dec ax

nxtvald5:
inc bx
mov dx,ax
call isIn ;;checks if the diagonals inside boundaries
cmp valid,1
jne noo5
mov cx,from_col
push cx
mov cx, from_row
push cx
mov from_row,ax
mov from_col,bx
call check_W_piece      ; checks if there is enemy in the diagonals to be eaten, if thereis highlight
pop cx
mov from_row,cx
pop cx
mov from_col,cx
mov cx,0
cmp wFound,cx
je noo5
mov valid_col,bl
mov valid_row,al
call draw_black_valid
call markthisCellB
noo5:        ;doing the same checks for the other diagonal
sub bx,2
mov dx,ax
call isIn     
cmp valid,1
jne outt5
mov cx,from_col
push cx
mov cx, from_row
push cx
mov from_row,ax
mov from_col,bx
call check_W_piece      ; checks if there is enemy in the diagonals to be eaten, if thereis highlight
pop cx

mov from_row,cx
pop cx
mov from_col,cx
mov cx,0
cmp wFound,cx
je outt5
mov valid_col,bl
mov valid_row,dl
call draw_black_valid
call markthisCellB
jmp outt5

outt5:
pop cx
mov wPiece,cx
pop cx
mov wFound,cx
pop_all
ret
Bpawn_draw_valid endp

;--------------------------------------------------------------------------------------------------------------------------

draw_continous_valid proc ;loops over the offsets of (bishop & rook ) depth first untill it reaches dead end, and validate each cell to draw the highlight
push_all
mov bx, from_col
mov ax,from_row
mov di,offset boardMap
mov cl,4
loopOnAllDirection1: ; loop on each offset
eachDirection1:  ; loops again and again  with same offset untill it reaches dead end 
add al,[si+1]
add bl,[si]
mov dx,ax
call isIn     ; checking for the boundaries
cmp valid,1
je oka1
jmp anotherDirec1 ; try another offset
oka1: 
push ax
push di
mov dx,8
mul dl
add ax,bx
add di,ax
mov ch,00
cmp [di],ch  ; if the cell is empty
je ye5s
mov ch,0AAh  ; checks if there is power up
cmp [di],ch
jne piecefound1 ; if there is piece
ye5s:
pop di
pop ax
mov valid_row,al
mov valid_col,bl
call draw_white_valid
call markthisCellW
jmp eachDirection1
piecefound1: ;checks if it is enemy or of the same type
pop di
pop ax
mov dx,ax
call is_W_here
mov dl,1
cmp valid,dl
jne anotherDirec1
mov valid_col,bl
mov valid_row,al
call draw_white_valid
call markthisCellW
anotherDirec1:
add si,2
mov bx,from_col
mov ax,from_row
dec cl
jnz x12
jmp sss1
x12: jmp loopOnAllDirection1
sss1:
pop_all
ret
draw_continous_valid endp

;----------------------------------------------------------------------------------------------

Bdraw_continous_valid proc      ;loops over the offsets of (bishop & rook ) depth first untill it reaches dead end, and validate each cell to draw the highlight
push_all
mov bx, from_col_
mov ax,from_row_
mov di,offset boardMap
mov cl,4
loopOnAllDirection19: ; loop on each offset
eachDirection19:    ; loops again and again  with same offset untill it reaches dead end 

add al,[si+1]
add bl,[si]
mov dx,ax
call isIn     ; checking for the boundaries
cmp valid,1
je oka19
jmp anotherDirec19  ; try another offset
oka19: 
push ax
push di
mov dx,8
mul dl
add ax,bx
add di,ax
mov ch,00
cmp [di],ch    ; if the cell is empty
je ye6s
mov ch,0AAh
cmp [di],ch    ; checks if there is power up
jne piecefound19
ye6s:
pop di
pop ax
mov valid_row,al
mov valid_col,bl
call draw_black_valid
call markthisCellB
jmp eachDirection19
piecefound19:   ; if there is piece
pop di
pop ax
mov dx,ax
call is_B_here    ;checks if it is enemy or of the same type
mov dl,1
cmp valid,dl
jne anotherDirec19
mov valid_col,bl
mov valid_row,al
call draw_black_valid
call markthisCellB
anotherDirec19:
add si,2
mov bx,from_col_
mov ax,from_row_
dec cl
jnz x129
jmp sss19
x129: jmp loopOnAllDirection19
sss19:
pop_all
ret
Bdraw_continous_valid endp

;--------------------------------------------------------------------------------------------------------------------------

queen_draw_valid proc ; queen = rook + bishop
push_all
  mov si, offset bishopOffset
call draw_continous_valid
  mov si, offset RookOffset
call draw_continous_valid
pop_all
ret
queen_draw_valid endp

;-------------------------------------------------------------------------------------------------------------------
Bqueen_draw_valid proc  ; queen = rook + bishop
push_all
  mov si, offset bishopOffset
call Bdraw_continous_valid
  mov si, offset RookOffset
call Bdraw_continous_valid
pop_all
ret
Bqueen_draw_valid endp

;--------------------------------------------------------------------------------------------------------------------------

king_draw_valid proc ;it validates the moves of the king (the 8 directions around it)
push_all
mov cx,8d
mov di, offset kingOffset

cont1: 
mov bx,from_col
mov dx,from_row
mov al,[di]
add bl,al
mov al,[di+1]
add dl,al
add di,2
call isIn
cmp valid,1
jne not_valid1

call is_W_here

cmp valid,1
jne not_valid1
mov valid_col,bl
mov valid_row,dl
call draw_white_valid
call markthisCellW
not_valid1:
dec cx
jnz cont1
pop_all
ret
king_draw_valid endp


;---------------------------------------------------------------------------------------------------------------------------------


Bking_draw_valid proc
push_all
mov cx,8d
mov di, offset kingOffset

cont17: 
mov bx,from_col_
mov dx,from_row_
mov al,[di]
add bl,al
mov al,[di+1]
add dl,al
add di,2
call isIn
cmp valid,1
jne not_valid17

call is_B_here

cmp valid,1
jne not_valid17
mov valid_col,bl
mov valid_row,dl
call draw_black_valid
call markthisCellB
not_valid17:
dec cx
jnz cont17
pop_all
ret
Bking_draw_valid endp
;------------------------------------------------------- Freezing -------------------------------------------------------------------
FreezingW proc 
PUSH_ALL
;check if u move to the same cell
mov ax,from_col
cmp ax,to_col
jne c_o_n
mov ax,from_row
cmp ax,to_row
jne c_o_n
ret
c_o_n:
; store the last move time
    lea bx,LastMoveTime
    mov ax,to_row
    mov cl,8
    mul cl
    add ax,to_col
    add bx,ax
    mov al,WFT
    mov [bx],al
    mov ax,col
    mov bx,row
    mov cx, shape_to_draw
    mov dx,to_col
    mov col,dx
    mov dx,to_row
    mov row,dx
    mov dx,offset locker
    mov shape_to_draw,dx
    call draw_cell
    mov col,ax
    mov row,bx
    mov shape_to_draw,cx
POP_ALL
     ret 
FreezingW endp

FreezingB proc 
PUSH_ALL
;check if u move to the same cell
mov ax,from_col_
cmp ax,to_col_
jne c_o_n_
mov ax,from_row_
cmp ax,to_row_
jne c_o_n_
ret
c_o_n_:
; store the last move time
    lea bx,LastMoveTime
    mov ax,to_row_
    mov cl,8
    mul cl
    add ax,to_col_
    add bx,ax
    mov al,BFT
    mov [bx],al
    mov ax,col
    mov bx,row
    mov cx, shape_to_draw
    mov dx,to_col_
    mov col,dx
    mov dx,to_row_
    mov row,dx
    mov dx,offset locker
    mov shape_to_draw,dx
    call draw_cell
    mov col,ax
    mov row,bx
    mov shape_to_draw,cx
POP_ALL
     ret 
FreezingB endp
;-------------------------------------------------------------------------------------------------------------------------------------
update_Last_move_time proc far
     push_all
    lea bx,LastMoveTime
    mov cx,64
      update_loop:
        mov al,[bx]
        cmp al,0
        je update_loop_end
        sub al,1
        mov [bx],al
        cmp al,0
        Jne update_loop_end
        call delete_locker
      update_loop_end:
      inc bx
      loop update_loop
    pop_all
     ret
update_Last_move_time endp
;-------------------------------------------------------------------------------------------------------------------------------------
delete_locker proc 
     push_all
        mov ax,64
    sub ax,cx
     mov dh,8
     div dh
     mov cx,0
     mov cl,al
     mov del_row,cx
     mov cl,ah
     mov del_col,cx
    mov ax,del_col
    add ax,del_row
    and ax,0001h
    cmp ax,0000h
    jne delete_lockerBcell
    lea bx,unlocker_white
    jmp delete_locker_con
    delete_lockerBcell:
    lea bx,unlocker_black
    delete_locker_con:
    mov ax,64
    sub ax,cx
    mov si,col
    mov dx,row
    mov cx, shape_to_draw
    mov shape_to_draw,bx

 mov ax ,del_row
     mov row,ax
mov ax,del_col
     mov col,ax
    call draw_cell
    mov col,si
    mov row,dx
    mov shape_to_draw,cx
    pop_all
     ret
delete_locker endp
;------------------------------------------------------- PowerUp bonus 1-------------------------------------------------------------------
PowerUp proc 
PUSH_ALL
    cmp player_mode,2
    jne skip_recieve_star
    start_recieve_star:
    mov dx , 3FDH		;Line Status Register
    in al , dx 
    and al , 00000001b
    Jnz recieve_star_con
    jmp start_recieve_star
    recieve_star_con:
    ;If Ready read the VALUE in Receive data register
    mov dx , 3F8H
    in al , dx 
    mov ah,0
    jmp skip_send_star
    skip_recieve_star:
;get time.
     mov  ah, 2ch
     int  21h
;get star location.
     mov ax,0
     mov al,dh
     mov dh,31
     div dh
     add ah ,16
     mov al,ah
     mov ah,0
     mov cx,ax
    cmp player_mode,1
    jne skip_send_star
  indicator_again_star:
  mov dx , 3FDH		;Line Status Register
  In al , dx 			;Read Line Status
  AND al , 00100000b
  JZ indicator_again_star
  mov dx , 3F8H		
  mov ax,cx
  out dx,al


    skip_send_star:
;set star in boardMap
    mov si,offset boardMap
    add si,ax
    mov cl,0AAh
    mov[si],cl

;get star col,row.
    mov dh,8
    div dh
    mov cx,0
    mov cl,al
    mov row,cx
    mov cl,ah
    mov col,cx
     mov shape_to_draw,offset Star
     call draw_cell
POP_ALL
     ret 
PowerUp endp
;-----------------------------------------------------------------------------------------------------------------------------------------
check_wking_threat proc  ; used to validate if there is a check for the white king
push_all
; first validate pawn check
mov dl,Wking_row
mov bl,Wking_col
mov bh,0
mov dh,0
dec dl
inc bl
call isIn
cmp valid,1
jne nxt_dia_check
call is_B_here
cmp valid,0
jne nxt_dia_check
call is_Bpawn
cmp valid,1
jne nxt_dia_check
mov cl,1
mov W_threat,cl
jmp threat_exit
;validate the other diagonal
nxt_dia_check:
sub bl,2
call isIn
cmp valid,1
jne nxt_type_vald
call is_B_here
cmp valid,0
jne nxt_type_vald
call is_Bpawn
cmp valid,1
jne nxt_type_vald
mov cl,1
mov W_threat,cl
jmp threat_exit
nxt_type_vald:


;validate if bishop check king
mov si,offset bishopOffset
mov bl,Wking_col
mov al,Wking_row
mov bh,0
mov ah,0
mov di,offset boardMap
mov cl,4
threat_loopOnAllDirection1: ; loop on each offset
threat_eachDirection1:  ; loops again and again  with same offset untill it reaches dead end 
add al,[si+1]
add bl,[si]
mov dx,ax
call isIn     ; checking for the boundaries
cmp valid,1
je threat_oka1
jmp threat_anotherDirec1 ; try another offset
threat_oka1: 
push ax
push di
mov dx,8
mul dl
add ax,bx
add di,ax
mov ch,00
cmp [di],ch  ; if the cell is empty
je threat_ye5s
mov ch,0AAh  ; checks if there is power up
cmp [di],ch
jne threat_piecefound1 ; if there is piece
threat_ye5s:
pop di
pop ax
jmp threat_eachDirection1
threat_piecefound1: ;checks if it is enemy or of the same type
pop di
pop ax
mov dx,ax
call is_B_here
mov dl,0
cmp valid,dl
jne threat_anotherDirec1
cmp bishop_Rook_flag,1
jne check_if_Rook
call is_Bbishop
jmp continue_Usual
check_if_Rook:
call is_Brook
continue_Usual:
cmp valid,1
jne checkbqueen
mov dl,1
mov W_threat,dl
jmp threat_exit
checkbqueen:
call is_Bqueen
cmp valid,1
jne threat_anotherDirec1
mov dl,1
mov W_threat,dl
jmp threat_exit
threat_anotherDirec1:
add si,2
mov bl,Wking_col
mov al,Wking_row
mov ah,0
mov bh,0
dec cl
jnz threat_x12
jmp nxtnxtVald
threat_x12:jmp threat_loopOnAllDirection1
nxtnxtVald:
cmp bishop_Rook_flag,1
jne nxtkingvald
mov bishop_Rook_flag,0
mov si,offset rookOffset
mov bl,Wking_col
mov al,Wking_row
mov bh,0
mov ah,0
mov di,offset boardMap
mov cl,4
jmp threat_loopOnAllDirection1


;////////////////////////////////////////////////////////////////////////////////
nxtkingvald:
;validate if king check king
mov cx,8d
mov di, offset kingOffset

threat_cont1: 
mov bl,Wking_col
mov dl,Wking_row
mov bh,0
mov dh,0
mov al,[di]
add bl,al
mov al,[di+1]
add dl,al
add di,2
call isIn
cmp valid,1
jne threat_not_valid1

call is_B_here

cmp valid,0
jne threat_not_valid1
call is_Bking
cmp valid,1
jne threat_not_valid1
mov dl,1
mov W_threat,dl
jmp threat_exit
threat_not_valid1:
dec cx
jnz threat_cont1


;validate if knight check king

mov cx,8d
mov di, offset knightOffset
threat_cont: 
mov bl,Wking_col
mov dl,Wking_row
mov bh,0
mov dh,0
mov al,[di]
add bl,al
mov al,[di+1]
add dl,al
add di,2
call isIn
cmp valid,1
jne threat_not_valid
call is_B_here      ; checks if there is a piece of the same type , if not continue, if there is do not draw highlight
cmp valid,0
jne threat_not_valid
call is_Bknight
cmp valid,1
jne threat_not_valid
mov dl,1
mov W_threat,dl
jmp threat_exit
threat_not_valid:
dec cx
jnz threat_cont

threat_exit:
mov bishop_Rook_flag,1
pop_all
ret
check_wking_threat endp

;-----------------------------------------------------------  --------------------------------
check_bking_threat proc  ; used to validate if there is a check for the white king
push_all
; first validate pawn check
mov dl,Bking_row
mov bl,Bking_col
mov bh,0
mov dh,0
inc dl
inc bl
call isIn
cmp valid,1
jne nxt_dia_check_
call is_W_here
cmp valid,0
jne nxt_dia_check_
call is_Wpawn
cmp valid,1
jne nxt_dia_check_
mov cl,1
mov B_threat,cl
jmp threat_exit_
;validate the other diagonal
nxt_dia_check_:
sub bl,2
call isIn
cmp valid,1
jne nxt_type_vald_
call is_W_here
cmp valid,0
jne nxt_type_vald_
call is_Wpawn
cmp valid,1
jne nxt_type_vald_
mov cl,1
mov B_threat,cl
jmp threat_exit_
nxt_type_vald_:

;validate if bishop check king
mov si,offset bishopOffset
mov bl,Bking_col
mov al,Bking_row
mov bh,0
mov ah,0
mov di,offset boardMap
mov cl,4
threat_loopOnAllDirection1_: ; loop on each offset
threat_eachDirection1_:  ; loops again and again  with same offset untill it reaches dead end 
add al,[si+1]
add bl,[si]
mov dx,ax
call isIn     ; checking for the boundaries
cmp valid,1
je threat_oka1_
jmp threat_anotherDirec1_ ; try another offset
threat_oka1_: 
push ax
push di
mov dx,8
mul dl
add ax,bx
add di,ax
mov ch,00
cmp [di],ch  ; if the cell is empty
je threat_ye5s_
mov ch,0AAh  ; checks if there is power up
cmp [di],ch
jne threat_piecefound1_ ; if there is piece
threat_ye5s_:
pop di
pop ax
jmp threat_eachDirection1_
threat_piecefound1_: ;checks if it is enemy or of the same type
pop di
pop ax
mov dx,ax
call is_W_here
mov dl,0
cmp valid,dl
jne threat_anotherDirec1_
cmp bishop_Rook_flag,1
jne check_if_Rook_
call is_Wbishop
jmp continue_Usual_
check_if_Rook_:
call is_Wrook
continue_Usual_:
cmp valid,1
jne checkwqueen
mov dl,1
mov B_threat,dl
jmp threat_exit_
checkwqueen:
call is_Wqueen
cmp valid,1
jne threat_anotherDirec1_
mov dl,1
mov B_threat,dl
jmp threat_exit_
threat_anotherDirec1_:
add si,2
mov bl,Bking_col
mov al,Bking_row
mov ah,0
mov bh,0
dec cl
jnz threat_x12_
jmp nxtnxtVald_
threat_x12_:jmp threat_loopOnAllDirection1_
nxtnxtVald_:
cmp bishop_Rook_flag,1
jne nxtkingvald_
mov bishop_Rook_flag,0
mov si,offset rookOffset
mov bl,Bking_col
mov al,Bking_row
mov bh,0
mov ah,0
mov di,offset boardMap
mov cl,4
jmp threat_loopOnAllDirection1_


;////////////////////////////////////////////////////////////////////////////////
nxtkingvald_:
;validate if king check king
mov cx,8d
mov di, offset kingOffset

threat_cont1_: 
mov bl,Bking_col
mov dl,Bking_row
mov bh,0
mov dh,0
mov al,[di]
add bl,al
mov al,[di+1]
add dl,al
add di,2
call isIn
cmp valid,1
jne threat_not_valid1_

call is_W_here

cmp valid,0
jne threat_not_valid1_
call is_Wking
cmp valid,1
jne threat_not_valid1_
mov dl,1
mov B_threat,dl
jmp threat_exit_
threat_not_valid1_:
dec cx
jnz threat_cont1_


;validate if knight check king

mov cx,8d
mov di, offset knightOffset
threat_cont_: 
mov bl,Bking_col
mov dl,Bking_row
mov bh,0
mov dh,0
mov al,[di]
add bl,al
mov al,[di+1]
add dl,al
add di,2
call isIn
cmp valid,1
jne threat_not_valid_
call is_W_here      ; checks if there is a piece of the same type , if not continue, if there is do not draw highlight
cmp valid,0
jne threat_not_valid_
call is_Wknight
cmp valid,1
jne threat_not_valid_
mov dl,1
mov B_threat,dl
jmp threat_exit_
threat_not_valid_:
dec cx
jnz threat_cont_

threat_exit_:
mov bishop_Rook_flag,1
pop_all
ret
check_bking_threat endp
;-----------------------------------------------------------------------------------------------------------------------------------------
play proc far
    call init_draw
    cmp player_mode,0
    je no_inline_names
    call show_player_name
    no_inline_names:
    call PowerUp
    playing:
        call Timer
        call player_movement
        call recieve_game

        cmp EndGame,0
        je continue_game
        wait_F4:
            ;if in multiplayer mode we send f4 to the other player to return them to the menu
            cmp player_mode,0
            je no_recieve_f4
            call recieve_game
            cmp player_mode,3
            je f4_recieved
            no_recieve_f4:

            mov ah,1
            int 16h
            jz wait_F4
            mov ah,0
            int 16h
            cmp ah,3eh
            je F4_pressed
        jmp wait_F4
        continue_game:
        ;a player pressed f4 in the middle of the game, so we set player_mode to 3 inside player_movement and return to menu
        cmp player_mode,3
        je F4_pressed
    jmp playing

    F4_pressed:   
    send_f4_again:
    mov dx , 3FDH		;Line Status Register
    In al , dx 			;Read Line Status
    AND al , 00100000b
    JZ send_f4_again
    
    mov dx,3F8H		
    mov al,7
    out dx,al
    f4_recieved:
    ret 
play endp
end
