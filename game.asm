include macros.inc

extrn init_draw:far
extrn draw_cell:far
extrn get_cell_start:far
extrn draw_selector1:far
extrn draw_selector2:far

extrn white_deselector:byte
extrn black_deselector:byte
extrn red_mark:byte
extrn blue_mark:byte

extrn shape_to_draw:word
extrn row:word
extrn col:word
extrn cell_start:word

public s1_row, s1_col, s2_row, s2_col, player_mode, play

.MODEL small
.stack 64
.DATA 
player_mode db 3    ;both_players:0 player1:1 player2:2 return_to_menu:3 
s1_row dw 7
s1_col dw 4
s1_color db 0       ;the cell color s1 is standing on, 0:black 0ffh:white
s2_row dw 0
s2_col dw 4
s2_color db 0ffh    ;the cell color s2 is standing on, 0:balck 0ffh:white
direction db 0      ;up:0 down:1 left:2 right:3

.code
;scan codes in hex
;w:11   s:1f    a:1e    d:20     q:10 
;up:48 down:50 left:4b right:4d r_shift:36 

;-----------------------------------listener for both players, changed with player mode-------------------------------------------
player_movement proc far
    ;gets the key pressed and checks if it concerns a player, then calls the appropriate function
    mov ah,1
    int 16h
    jz no_key_pressed_game
    mov ah,0
    int 16h

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

    cmp ah,01h
    je game_to_menu

    ;the key pressed doesn't concern players
    no_key_pressed_game:
    ret
 
    ;player mode 3 is a code for returning to the menu
    game_to_menu:
    mov player_mode,3
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

    move1:
    call move_selector1
    ret

    move2:
    call move_selector2
    ret
    
    
player_movement endp

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
