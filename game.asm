include macros.inc

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

extrn white_deselector:byte
extrn black_deselector:byte
extrn red_mark:byte
extrn blue_mark:byte
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

extrn shape_to_draw:word
extrn row:word
extrn col:word
extrn cell_start:word
extrn inline_x:byte
extrn inline_y:byte

public s1_row, s1_col, s2_row, s2_col, player_mode, play,boardMap,from_row,from_col,to_row,to_col,wFound,bFound,boardMap,wPiece,bPiece,from_row_,from_col_,to_row_,to_col_

.MODEL small
.stack 64
.DATA 
player_mode db 3    ;both_players:0 player1:1 player2:2 return_to_menu:3 
;---------------------------- move from cell to cell ----------------------------
from_row dw 8
from_col dw 8
from_color dw 0 
to_row dw 0
to_col dw 0
to_color dw 0 
wFound dw 0 
wPiece dw 0
bPiece dw 0
bFound dw 0 
from_row_ dw 8
from_col_ dw 8
from_color_ dw 0 
to_row_ dw 0
to_col_ dw 0
to_color_ dw 0 
;-----------------------------------------------------------------------------
player_chat db 0
s1_row dw 7
s1_col dw 4
s1_color db 0       ;the cell color s1 is standing on, 0:black 0ffh:white
s2_row dw 0
s2_col dw 4
s2_color db 0ffh    ;the cell color s2 is standing on, 0:balck 0ffh:white
direction db 0      ;up:0 down:1 left:2 right:3
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



.code
;scan codes in hex
;w:11   s:1f    a:1e    d:20     q:10   1:02
;up:48 down:50 left:4b right:4d r_shift:36 

;-----------------------------------listener for both players, changed with player mode-------------------------------------------
player_movement proc far
    ;gets the key pressed and checks if it concerns a player, then calls the appropriate function
    mov ah,1
    int 16h
    jz no_key_pressed_game
    mov ah,0
    int 16h

    cmp ah,02h
    je toggle_inline_chat

    cmp player_chat,0ffh
    je active_inline_chat

    cmp ah,01h
    je game_to_menu
    
    ;listens depending on the player_mode
    cmp player_mode,2
    je only_player2

    ;WASD + Q
    cmp ah,11h
    je up1
    cmp ah,1fh
    je down1
    cmp ah,1eh
    je left1
    cmp ah,20h
    je right1
    cmp ah,10h
    je select1

    ;skip player2 if the mode is set to 1
    cmp player_mode,1
    je no_key_pressed_game

    ;arrow keys + RShift
    only_player2:
    cmp ah,48h
    je up2
    cmp ah,50h
    je down2
    cmp ah,4bh
    je left2
    cmp ah,4dh
    je right2
    cmp ah,12h
    je select2

    ;the key pressed doesn't concern players
    no_key_pressed_game:
    ret

    ;player mode 3 is a code for returning to the menu
    game_to_menu:
    mov player_mode,3
    ret

    toggle_inline_chat:
    not player_chat
    cmp player_chat,0
    je back_to_game
    call show_player_name
    back_to_game:
    ret

    active_inline_chat:
    call inline_chat
    ret

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
;----------------------------------------------
    select1:
    call Select_W
    ret
;----------------------------------------------
    select2:
    call Select_B
    ret
;----------------------------------------------

    move1:
    call move_selector1
    ret

    move2:
    call move_selector2
    ret
    
    
player_movement endp
;--------------------------------------------------------------------------------------------------------------

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
    jne no_overlapping1
    mov ax,s1_col
    cmp ax,s2_col
    jne no_overlapping1

    ;both selectors overlapped, so we draw the other selector since we just erased it
    call draw_selector2

    no_overlapping1:
    pop ax
    ret
deselect1 endp
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
    jne no_overlapping2
    mov ax,s1_col
    cmp ax,s2_col
    jne no_overlapping2

    ;both selectors overlapped, so we draw the other selector since we just erased it
    call draw_selector1

    no_overlapping2:
    pop ax
    ret
deselect2 endp
;--------------------------------------------------------------------------------------------------------------------------
Select_W proc 
    cmp from_col,8
    je skip
    call Change_W_place
    ret
    skip:
    PUSH_ALL
    mov ax,s1_col
    mov from_col,ax
    mov ax,s1_row
    mov from_row,ax
    mov ax,s1_color
    mov from_color,ax
    call check_W_piece
    cmp wFound,1
    je CheckEnd
    mov ax,8
    mov from_col,ax
    mov from_row,ax
    CheckEnd:
    mov wFound,0
    POP_ALL
    ret
Select_W endp
Select_B proc 
    cmp from_col_,8
    je skip_
    call Change_B_place
    ret
    skip_:
    PUSH_ALL
    mov ax,s2_col
    mov from_col_,ax
    mov ax,s2_row
    mov from_row_,ax
    mov ax,s2_color
    mov from_color_,ax
    call check_B_piece
    cmp bFound,1
    je CheckEnd_
    mov ax,8
    mov from_col_,ax
    mov from_row_,ax
    CheckEnd_:
    mov bFound,0
    POP_ALL
    ret
Select_B endp
Change_W_place proc 
push ax
    mov ax,s1_col
    mov to_col,ax
    mov ax,s1_row
    mov to_row,ax
    mov ax,s1_color
    mov to_color,ax
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
    mov ax,to_row
    mov s1_row,ax
    mov ax,to_col
    mov s1_col,ax
    pop ax
        PUSH_ALL
    lea bx,boardMap
    mov ax,from_row
    mov cl,8
    mul cl
    add ax,from_col
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
    add bx,ax
    pop ax
    mov [bx],al
    mov ax,wPiece
    mov shape_to_draw,ax
    draw_:
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
    mov ax,s2_col
    mov to_col_,ax
    mov ax,s2_row
    mov to_row_,ax
    mov ax,s2_color
    mov to_color_,ax
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
    lea bx,boardMap
    mov ax,from_row_
    mov cl,8
    mul cl
    add ax,from_col_
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
    add bx,ax
    pop ax
    mov [bx],al
    mov ax,bPiece
    mov shape_to_draw,ax
    draw__:
    mov ax,8
    mov from_col_,ax
    mov from_row_,ax
    POP_ALL
    call move_piece_
    call draw_selector1
    call draw_selector2
    ret
Change_B_place endp
;--------------------------------------------------------------------------------------------------------------------------
play proc far
    call init_draw
    playing:
        call player_movement
        
        ;we set the player_mode to 3 inside player movement whenever ESC is pressed
        cmp player_mode,3
        je esc_pressed
    jmp playing

    esc_pressed:
    ret 
play endp
end
