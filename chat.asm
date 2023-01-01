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


;---------------------------------------------------------
extrn player_name:byte
extrn other_player_name:byte
extrn player_mode:byte

public chat_mode

;------------------------------------------------------

.MODEL small
.data
    MESSAGE_OFFSET DW ?
    X_now              DB 0
    Y_now              DB 0
    X_ME           DB 3
    Y_ME           DB 0
    X_YOU          DB 4
    Y_YOU          DB 13
    LINE           DB "------------------------------------------------------------------------------------$"
    mrk            db ":$"
    _ah            db ? 
.code

Show_Message_chat PROC
                 PUSH_ALL
                 mov      ah,9h
                 mov      dx,MESSAGE_OFFSET
                 int      21h
                 POP_ALL
                 RET
Show_Message_chat ENDP

CURSOR_GOTO PROC
                 PUSH_ALL
                 mov      ah,02h
                 mov      bh,0
                 mov      dl,X_now
                 mov      dh,Y_now
                 int      10h
                 POP_ALL
                 RET
CURSOR_GOTO ENDP

CURSOR_ME PROC
                 PUSH_ALL
                 MOV      BL,X_ME
                 MOV      X_now,BL
                 MOV      BL,Y_ME
                 MOV      Y_now,BL
                 POP_ALL
                 RET
CURSOR_ME ENDP

CURSOR_YOU PROC
                 PUSH_ALL
                 MOV      BL,X_YOU
                 MOV      X_now,BL
                 MOV      BL,Y_YOU
                 MOV      Y_now,BL
                 POP_ALL
                 RET
CURSOR_YOU ENDP
; ;--------------------------------------------------------------------------
; save_firstline PROC
;      PUSH_ALL
;     mov ax, ds
;     mov es, ax
;     lea di, firstline
;     mov ax, 0b800h
;     mov ds, ax
;     mov ax, 0
;     mov si, ax
;     mov cx, 80
;     rep movsw
;     POP_ALL
;     ret
; save_firstline ENDP

; restore_firstline PROC
;      PUSH_ALL
;     lea si, firstline
;     mov ax, 0b800h
;     mov es, ax
;     mov ax, 0
;     mov di, ax
;     mov cx, 80
;     rep movsw
;      POP_ALL
;     ret
; restore_firstline ENDP

; scroll_up PROC
;      PUSH_ALL
;     call save_firstline
;     mov ah, 6               
;     mov al, 1               ; number of lines to scroll
;     mov bh, 0               ; attribute
;     mov ch, 0               ; row top
;     mov cl, 0               ; col left
;     mov dh, 25              ; row bottom
;     mov dl, 80              ; col right
;     int 10h
;      POP_ALL
;     ret
; scroll_up ENDP

; scroll_down PROC
;      PUSH_ALL
;     mov ah, 7             
;     mov al, 1               ; number of lines to scroll
;     mov bh, 0               ; attribute
;     mov ch, 0               ; row top
;     mov cl, 0               ; col left
;     mov dh, 25              ; row bottom
;     mov dl, 80              ; col right
;     int 10h
;     call restore_firstline
;      POP_ALL
;     ret
; scroll_down ENDP 
; --------------------------------------------------------------------------
chat_mode proc FAR
    ;CHAT SCREEN
                 MOV      AH,0
                 MOV      AL,3
                 INT      10H

                 MOV      X_now,0

                 MOV      Y_now,12
                 CALL     CURSOR_GOTO
                 MOV      MESSAGE_OFFSET,OFFSET LINE
                 CALL     Show_Message_chat

                 MOV      Y_now,1
                 MOV      X_now,1 
                 CALL     CURSOR_GOTO
                 MOV      MESSAGE_OFFSET,OFFSET player_name
                 CALL     Show_Message_chat
                 MOV      MESSAGE_OFFSET,OFFSET mrk
                 CALL     Show_Message_chat



                 MOV      Y_now,13
                 CALL     CURSOR_GOTO
                
                 MOV      MESSAGE_OFFSET,OFFSET other_player_name
                 CALL     Show_Message_chat
                 MOV      MESSAGE_OFFSET,OFFSET mrk
                 CALL     Show_Message_chat

                 MOV      X_ME,2
                 MOV     Y_ME,2
                 MOV      X_YOU,2
                 MOV     Y_YOU,14

    CHAT:        
    ;Check that Transmitter Holding Register is Empty
                 mov      dx , 3FDH                     ; Line Status Register
    
                 In       al , dx                       ;Read Line Status
                 AND      al , 00100000b
                 JNZ      SEND_CHECK

    ;If empty put the VALUE in Transmit data register
    SEND_CHECK:  
                 MOV      AH,1
                 INT      16H
                 JZ       DONE1

    ;KEY PRESSED, GET IT
                 MOV      AH,0
                 INT      16H
                 mov      _ah,ah
                 CMP      AH,1CH
                 JNE      NOT_ENTER
                 INC      Y_ME
                 MOV      X_ME,0
                 JMP      DONE_ENTER
    NOT_ENTER:   
            
                 CALL     CURSOR_ME
                 CALL     CURSOR_GOTO
                 INC      X_ME

                 MOV      AH,2
                 MOV      DL,AL
                 INT      21H

    DONE_ENTER:  
                 mov      dx , 3F8H                     ; Transmit data register
                 out      dx , al

    DONE1:       
    
    ;RECIEVE
    ;Check that Data Ready
                 mov      dx , 3FDH                     ; Line Status Register
                 in       al , dx
                 AND      al , 1
                 JZ       DONT_PRINT

    ;If Ready read the VALUE in Receive data register
                 mov      dx , 03F8H
                 in       al , dx
                 mov      DL , al

                 cmp al,7 
                 je go_to_menu2


                 CMP      aL,13
                 JNE      NOT_ENTER2
                 INC      Y_YOU
                 MOV      X_YOU,0
                 JMP      DONT_PRINT
    NOT_ENTER2:  

                 CALL     CURSOR_YOU
                 CALL     CURSOR_GOTO
                 INC      X_YOU

                 mov      ah, 2
                 int      21h
    DONT_PRINT:
                cmp _ah,3dh
                je go_to_menu
                JMP CHAT

    go_to_menu:
                mov dx,3f8h
                mov al,7
                out dx,al

   go_to_menu2:             
ret
chat_mode endp
end

