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
extrn menu:far

public chat_mode

;------------------------------------------------------

.MODEL small
.STACK 100h
.data
    chat_message_offset DW ?
    X_now              Dw 0
    Y_now              Dw 0
    X_ME           Dw 3
    Y_ME           Dw 0
    X_YOU          Dw 4
    Y_YOU          Dw 13
    LINE           DB "----------------------------------------------------------------------------$"
    YOU            DB "$"
    ME             DB "$"
    mrk             db ":$"
    _ah                 db ? 
.code

Show_Message_chat PROC
                 PUSH_ALL
                 mov      ah,9h
                 mov      dx,chat_message_offset
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

; --------------------------------------------------------------------------
chat_mode proc FAR
    ;CHAT SCREEN
                 MOV      AH,0
                 MOV      AL,3
                 INT      10H

                 



                 MOV      X_now,0

                 MOV      Y_now,12
                 CALL     CURSOR_GOTO
                 MOV      chat_message_offset,OFFSET LINE
                 CALL     Show_Message_chat

                 MOV      Y_now,1
                 MOV      X_now,1 
                 CALL     CURSOR_GOTO

                 MOV      chat_message_offset,OFFSET player_name[2]
                 CALL     Show_Message_chat

                MOV      chat_message_offset,OFFSET mrk
                CALL     Show_Message_chat



                 MOV      Y_now,13
                 CALL     CURSOR_GOTO
                
                 MOV      chat_message_offset,OFFSET other_player_name
                 CALL     Show_Message_chat
                MOV      chat_message_offset,OFFSET mrk
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

    ;K EY PRESSED, GET IT
                MOV      AH,0
                 INT      16H
                mov _ah,ah
                 CMP      AH,1CH
                 JNE      NOT_ENTER
                 INC      Y_ME
                 MOV      X_ME,0
                 JMP      DONE_ENTER
    NOT_ENTER:   
                    ;move cursor
                 CALL     CURSOR_ME
                 CALL     CURSOR_GOTO
                 INC      X_ME
                ;  cmp x_ME,80
                ;  jne  goo
                ;     cmp Y_ME,11
                ;     jne gooo
                ;     mov     ah, 06h ; scroll up function id.
                ;     mov     al, 2   ; lines to scroll.
                ;     mov     bh, 07  ; attribute for new lines.
                ;     mov     cl, 0   ; upper col.
                ;     mov     ch, 0   ; upper row.
                ;     mov     dl, 80  ; lower col.
                ;     mov     dh, 0   ; lower row.
                ;     int     10h
                ;     mov X_ME,0
                ;     mov Y_ME,9
                ;     CALL     CURSOR_ME
                ;  CALL     CURSOR_GOTO
                ; goo:
                ; gooo:
                 MOV      AH,2
                 MOV      DL,AL
                 INT      21H

    DONE_ENTER: 

                cmp _ah,3dh  
                je go_to_menu 
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
                 MOV      DL,AL
                 int      21h
    DONT_PRINT:
                
                JMP      CHAT
    go_to_menu:
                mov dx,3f8h
                mov al,7
                out dx,al
 
   go_to_menu2:             
ret
chat_mode endp
end

