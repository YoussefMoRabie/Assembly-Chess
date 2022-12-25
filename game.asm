include macros.inc

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


extrn white_deselector:byte
extrn black_deselector:byte
extrn red_mark:byte
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
Mahmoud db 4
cursor_dummy db 4
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
           db -1,-1
           db -1,1
            db 1,1
            db 1,-1
            

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
  mov WFT, 0  
  mov BFT, 0

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

    cmp ah,02h
    je toggle_inline_chat

    cmp player_chat,0ffh
    je active_inline_chat

    cmp ah,3eh
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
    cmp ah,35h
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
    je skip ; Jump if First Q
        call isMarkW  ;checks if this a valid cell to move to
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
    call check_wking_threat
    mov cl,1
    cmp W_threat,1
    jne nothreat
       ;mov cursor
     mov ah,2
     mov dx,1819h
     int 10h 
     mov ah, 9
    mov dx,offset W_threat_MSG
    int 21h
    mov W_threat,0
    ;updating the opponent's drawn valid cells (if exist) after my move
    nothreat: mov cx,8
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


Select_B proc ;Select Black piece to move it
    cmp from_col_,8 ; check if First E
    je skip_ ; Jump if First E
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
        call check_wking_threat
    mov cl,1
    cmp W_threat,1
    jne nothreat_
        ; mov cursor
     mov ah,2
     mov dx,1819h
     int 10h 
     mov ah, 9
    mov dx,offset W_threat_MSG
    int 21h
    mov W_threat,0
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
   notKing: mov ax,s1_col
    mov to_col,ax
    mov ax,s1_row
    mov to_row,ax
    mov ax,0
    mov al,s1_color
    mov to_color,ax
    ;---------Bonus
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
 ;Get the destination cell you want to move the piece to
    mov ax,s2_col
    mov to_col_,ax
    mov ax,s2_row
    mov to_row_,ax
    mov ax,0
    mov al,s2_color
    mov to_color_,ax
        ;---------Bonus
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
    ;
    ;
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
push_all
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
pop_all
ret
isIn endp

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
      update_loop_end:
      inc bx
      loop update_loop
    pop_all
     ret
update_Last_move_time endp
;------------------------------------------------------- PowerUp bonus 1-------------------------------------------------------------------
PowerUp proc 
PUSH_ALL
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
; mov dl,Wking_row
; mov bl,Wking_col
; mov bh,0
; mov dh,0
; dec dl
; inc bl
; call isIn
; cmp valid,1
; jne nxt_dia_check
; call is_B_here
; cmp valid,0
; jne nxt_dia_check
; call is_Bpawn
; cmp valid,1
; jne nxt_dia_check
; mov cl,1
; mov W_threat,cl
; jmp threat_exit
; ;validate the other diagonal
; nxt_dia_check:
; sub bl,2
; call isIn
; cmp valid,1
; jne nxt_type_vald
; call is_B_here
; cmp valid,0
; jne nxt_type_vald
; call is_Bpawn
; cmp valid,1
; jne nxt_type_vald
; mov cl,1
; mov W_threat,cl
; jmp threat_exit
; nxt_type_vald:
; mov ah,2
;   mov dx,041eh
;   int 10h 
; mov ah,2
;      mov dl,Wking_col
;      add dl,'0'
;      int 21h
; mov ah,2
;      mov dl,Wking_row
;      add dl,'0'
;      int 21h
;validate if bishop check king

mov si,offset bishopOffset
mov bl,Wking_col
mov al,Wking_row
mov bh,0
mov ah,0
mov di,offset boardMap


threat_loopOnAllDirection1: ; loop on each offset
threat_eachDirection1:  ; loops again and again  with same offset untill it reaches dead end 

add al,[si+1]
add bl,[si]
mov dx,ax
mov dh,0
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
call is_Bbishop
cmp valid,1
jne checkbqueen
mov dl,1
mov W_threat,dl
jmp threat_exit
checkbqueen:
call is_Bqueen
cmp valid,1
jne nxtnxtVald
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

;//////////////////////////////////////////////////////////////////////////////////

; mov si,offset RookOffset
; mov bl,Wking_col
; mov al,Wking_row
; mov bh,0
; mov ah,0
; mov di,offset boardMap
; mov cl,4
; rook_threat_loopOnAllDirection1: ; loop on each offset
; rook_threat_eachDirection1:  ; loops again and again  with same offset untill it reaches dead end 
; add al,[si+1]
; add bl,[si]
; mov dx,ax
; call isIn     ; checking for the boundaries
; cmp valid,1
; je rook_threat_oka1
; jmp rook_threat_anotherDirec1 ; try another offset
; rook_threat_oka1: 
; push ax
; push di
; mov dx,8
; mul dl
; add ax,bx
; add di,ax
; mov ch,00
; cmp [di],ch  ; if the cell is empty
; je rook_threat_ye5s
; mov ch,0AAh  ; checks if there is power up
; cmp [di],ch
; jne rook_threat_piecefound1 ; if there is piece
; rook_threat_ye5s:
; pop di
; pop ax
; jmp rook_threat_eachDirection1
; rook_threat_piecefound1: ;checks if it is enemy or of the same type
; pop di
; pop ax
; mov dx,ax
; call is_B_here
; mov dl,0
; cmp valid,dl
; jne rook_threat_anotherDirec1
; call is_Brook
; cmp valid,1
; jne rook_checkbqueen
; mov dl,1
; mov W_threat,dl
; jmp threat_exit
; rook_checkbqueen:
; call is_Bqueen
; cmp valid,1
; jne rook_nxtnxtVald
; mov dl,1
; mov W_threat,dl
; jmp threat_exit
; rook_threat_anotherDirec1:
; add si,2
; mov bl,Wking_col
; mov al,Wking_row
; mov ah,0
; mov bh,0
; dec cl
; jnz rook_threat_x12
; jmp rook_nxtnxtVald
; rook_threat_x12:jmp rook_threat_loopOnAllDirection1
; rook_nxtnxtVald:

;////////////////////////////////////////////////////////////////////////////////
; nxtkingvald:
; ;validate if king check king
; mov cx,8d
; mov di, offset kingOffset

; threat_cont1: 
; mov bl,Wking_col
; mov dl,Wking_row
; mov bh,0
; mov dh,0
; mov al,[di]
; add bl,al
; mov al,[di+1]
; add dl,al
; add di,2
; call isIn
; cmp valid,1
; jne threat_not_valid1

; call is_B_here

; cmp valid,0
; jne threat_not_valid1
; call is_Bking
; cmp valid,1
; jne threat_not_valid1
; mov dl,1
; mov W_threat,dl
; jmp threat_exit
; threat_not_valid1:
; dec cx
; jnz threat_cont1


; ;validate if knight check king

; mov cx,8d
; mov di, offset knightOffset
; threat_cont: 
; mov bl,Wking_col
; mov dl,Wking_row
; mov bh,0
; mov dh,0
; mov al,[di]
; add bl,al
; mov al,[di+1]
; add dl,al
; add di,2
; call isIn
; cmp valid,1
; jne threat_not_valid
; call is_B_here      ; checks if there is a piece of the same type , if not continue, if there is do not draw highlight
; cmp valid,0
; jne threat_not_valid
; call is_Bknight
; cmp valid,1
; jne threat_not_valid
; mov dl,1
; mov W_threat,dl
; jmp threat_exit
; threat_not_valid:
; dec cx
; jnz threat_cont

threat_exit:
pop_all
ret
check_wking_threat endp

;-----------------------------------------------------------------------------------------------------------------------------------------
play proc far
    call init_draw
    call PowerUp
    playing:
    call Timer
        call player_movement
        
        cmp EndGame,0
        je continue_game
        wait_F4:
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
    ret 
play endp
end
