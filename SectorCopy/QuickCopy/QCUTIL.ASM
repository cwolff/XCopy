NAME             QCUTIL
;
TITLE            QUICK_COPY 
;
SUBTTL           UTILITIES
;
PAGE 60,132
;
;**************************************************************************
;
;                COPYRIGHT 1982 SOFTWARE LABORATORIES INC.
;                AUTHOR CAMERON L WOLFF
;
;**************************************************************************
;
;CODE SEGMENT
;
CODE_SEG         SEGMENT               PUBLIC 'CODE'
;
INCLUDE          C:QCDATA.INC
;
                  PUBLIC START_DISP,DR2_DISP,SRCE_DISP
                  PUBLIC DEST_DISP,QUERRY_DISP,DISP_STRING
                  PUBLIC CLEAR_SCRN,CLEAR_WINDOW,RETURN
                  PUBLIC PROG_DISP,TRACK_OUT,ASCII_OUT
;
                  ASSUME CS:CODE_SEG  ;DATA_SEG        
;
PAGE
;
; QCUTIL CONTAINS MANY PROCEDURES USED BY QCDRVR AND QCERR.
; QCDRVR, QCUTIL, QCERR QND QCDATA ARE LINKED TOGETHER VIA THE
; LINKER. IF A PROGRAM HAS LABELS OR VARIABLES TO BE USED BY
; ANOTHER PROGRAM THEY MUST BE DECLARED PUBLIC. IF A PROGRAM IS
; TO USE LABELS OR VARIABLES DEFINED IN ANOTHER PROGRAM THEY MUST
; BE DECLARED EXTERNAL TO THE PROGRAM. AN INCLUDE FILE IS USEFULL
; IS MAKING THE SAME DECLARATIONS IN MORE THAN ONE PROGRAM (SUCH AS
; QCDATA.INC).
;
PAGE
;
;START_DISP
;
;          CLEARS SCREEN AND GENERATES STARTING DISPLAY
;
START_DISP        PROC                NEAR
;
                  MOV                 AL,COL_SIZE
                  MOV                 AH,QC_LEN
                  SUB                 AL,AH
                  SHR                 AL,1
;
                  MOV                 AH,0AH
                  MOV                 CH,70H
                  MOV                 CL,QC_LEN
                  MOV                 BX,OFFSET QC_MESS
                  CALL                DISP_STRING
;
                  MOV                 AL,COL_SIZE
                  MOV                 AH,DEV_LEN
                  SUB                 AL,AH
                  SHR                 AL,1
;
                  MOV                 AH,12H
                  MOV                 CH,70H
                  MOV                 CL,DEV_LEN
                  MOV                 BX,OFFSET DEV_MESS
                  CALL                DISP_STRING
;
                  MOV                 AX,20
TIME1:            MOV                 CX,7FFFH
TIME2:            DEC                 CX
                  JNZ                 TIME2
                  DEC                 AX
                  JNZ                 TIME1
;
                  RET
;
PAGE
;
START_DISP        ENDP
;
;
;DR2_DISP
;
;          DISPLAYS PROMPT FOR A TWO DRIVE SYSTEM.
;
DR2_DISP          PROC               NEAR
;
                  MOV                AL,COL_SIZE
                  MOV                AH,DR2_LEN1
                  SUB                AL,AH
                  SHR                AL,1
;
                  MOV                AH,10H
                  MOV                CH,07H
                  MOV                CL,DR2_LEN1
                  MOV                BX,OFFSET DR2_MESS1
                  CALL               DISP_STRING
;
                  MOV                AL,COL_SIZE
                  MOV                AH,DR2_LEN2
                  SUB                AL,AH
                  SHR                AL,1
;
                  MOV                AH,12H
                  MOV                CH,07H
                  MOV                CL,DR2_LEN2
                  MOV                BX,OFFSET DR2_MESS2
                  CALL               DISP_STRING
;
                  MOV                AL,COL_SIZE
                  MOV                AH,RET_LEN
                  SUB                AL,AH
                  SHR                AL,1
;
                  MOV                AH,14H
                  MOV                CH,07H
                  MOV                CL,RET_LEN
                  MOV                BX,OFFSET RET_MESS
                  CALL               DISP_STRING
;
                  CALL               RETURN
;
                  RET
;
DR2_DISP          ENDP
;
;
PAGE
;
;SRCE_DISP
;
;          PROMPTS USER TO INSERT SOURCE DISKETTE
;
SRCE_DISP         PROC               NEAR
;
                  MOV                AL,COL_SIZE
                  MOV                AH,SRCE_LEN
                  SUB                AL,AH
                  SHR                AL,1
;
                  MOV                AH,12H
                  MOV                CH,07H
                  MOV                CL,SRCE_LEN
                  MOV                BX,OFFSET SRCE_MESS
                  CALL               DISP_STRING
;
                  MOV                AL,COL_SIZE
                  MOV                AH,RET_LEN
                  SUB                AL,AH
                  SHR                AL,1
;
                  MOV                AH,14H
                  MOV                CH,07H
                  MOV                CL,RET_LEN
                  MOV                BX,OFFSET RET_MESS
                  CALL               DISP_STRING
;
                  CALL               RETURN
;
                  RET
;
SRCE_DISP         ENDP
;
;
PAGE
;
;DEST_DISP
;
;          PROMPTS USER TO INSERT DISTINATION DISKETTE
;
DEST_DISP         PROC               NEAR
;
                  MOV                AL,COL_SIZE
                  MOV                AH,DEST_LEN
                  SUB                AL,AH
                  SHR                AL,1
;
                  MOV                AH,12H
                  MOV                CH,07H
                  MOV                CL,DEST_LEN
                  MOV                BX,OFFSET DEST_MESS
                  CALL               DISP_STRING
;
                  MOV                AL,COL_SIZE
                  MOV                AH,RET_LEN
                  SUB                AL,AH
                  SHR                AL,1
;
                  MOV                AH,14H
                  MOV                CH,07H
                  MOV                CL,RET_LEN
                  MOV                BX,OFFSET RET_MESS
                  CALL               DISP_STRING
;
                  CALL               RETURN
;
                  RET
;
DEST_DISP         ENDP
;
;
PAGE
;
;QUERRY_DISP
;
;           ASK THE USER IF THEY WISH TO MAKE ANOTHER
;           COPY
;
QUERRY_DISP       PROC               NEAR
;
                  MOV                AL,COL_SIZE
                  MOV                AH,QUE_LEN1
                  SUB                AL,AH
                  SHR                AL,1
;
                  MOV                AH,10H
                  MOV                CH,07H
                  MOV                CL,QUE_LEN1
                  MOV                BX,OFFSET QUE_MESS1
                  CALL               DISP_STRING
;
                  MOV                AL,COL_SIZE
                  MOV                AH,QUE_LEN2
                  SUB                AL,AH
                  SHR                AL,1
;
                  MOV                AH,12H
                  MOV                CH,07H
                  MOV                CL,QUE_LEN2
                  MOV                BX,OFFSET QUE_MESS2
                  CALL               DISP_STRING
;
                  MOV                AL,COL_SIZE
                  MOV                AH,QUE_LEN3
                  SUB                AL,AH
                  SHR                AL,1
;
                  MOV                AH,14H
                  MOV                CH,07H
                  MOV                CL,QUE_LEN3
                  MOV                BX,OFFSET QUE_MESS3
                  CALL               DISP_STRING
;
                  RET
;
QUERRY_DISP       ENDP
;
;
PAGE
;
;RETURN
;
;          WAITS FOR A RETURN TO BE TYPED
;
RETURN            PROC               NEAR
;
                  MOV                AH,0
                  INT                16H
;
                  CMP                AL,0DH
                  JNZ                RETURN
;
                  RET
;
RETURN            ENDP
;
;
PAGE
;
;DISP_STRING
;
;           DISPLAY STRING DISPLAYS A MESSAGE STRING
;           TO THE DISPLAY
;
;           CS:BX POINTS TO A STRING
;           CH = ATTRIBUTE
;           CL = COUNT
;           AX = ROW,COUNT
;
DISP_STRING       PROC               NEAR
;
                  DEC                BX
                  MOV                C_PTR,BX
                  DEC                AX
                  MOV                ROWCOL,AX
                  MOV                ATTR,CH
                  AND                CX,0FFH
;
DISP_MORE:        PUSH               CX
                  MOV                AH,2
                  MOV                DX,ROWCOL
                  INC                DX
                  MOV                ROWCOL,DX
                  MOV                BH,ACT_PAGE
                  INT                10H
;
                  MOV                AH,9
                  MOV                CX,1
                  MOV                BX,C_PTR
                  INC                BX
                  MOV                C_PTR,BX
                  MOV                AL,[BX]
                  MOV                BL,ATTR
                  MOV                BH,ACT_PAGE
                  INT                10H
;
                  POP                CX
                  LOOP               DISP_MORE
;
                  RET
;
DISP_STRING       ENDP
;
;
PAGE
;
;CLEAR_SCRN
;
;           CLEARS THE SCREEN
;
CLEAR_SCRN        PROC                NEAR
;
                  MOV                 AH,6
                  MOV                 AL,0
                  MOV                 CX,0H
                  MOV                 DX,1750H
                  MOV                 BH,07H
                  INT                 10H
;
                  RET
;
CLEAR_SCRN        ENDP
;
;
PAGE
;
;CLEAR_WINDOW
;
;          CLEARS SCREEN AREA FOR ERROR MESSAGES
;          QUERRIES AND PROMPT
;
CLEAR_WINDOW      PROC                NEAR
;
                  MOV                 AH,6
                  MOV                 AL,0
                  MOV                 CX,0B00H
                  MOV                 DX,1750H
                  MOV                 BH,07H
                  INT                 10H
;
                  RET
;
CLEAR_WINDOW      ENDP
;
;
PAGE
;
;PROG_DISP
;
;          DISPLAY APPROPRIATE PROGRESS MESSAGE
;          AND CURRENT TRACK NUMBER
;
;          AL = 0 THEN DISPLAY DISK READ PROGRESS
;          AL = 1 THEN DISPLAY DISK WRITE PROGRESS
;          AL = 2 THEN DISPLAY DISK VERIFY PROGRESS
;
PROG_DISP         PROC              NEAR
;
                  PUSH              AX
;
                  OR                AL,AL
                  JZ                PROG_R
                  DEC               AL
                  JZ                PROG_W
;
PROG_V:           MOV               BX,OFFSET PROG_V_M
                  MOV               AL,COL_SIZE
                  MOV               AH,PROG_V_LEN
                  SUB               AL,AH
                  SHR               AL,1
                  MOV               CL,PROG_V_LEN
                  JMP               PROG_OUT
;
PROG_R:           MOV               BX,OFFSET PROG_R_M
                  MOV               AL,COL_SIZE
                  MOV               AH,PROG_R_LEN
                  SUB               AL,AH
                  SHR               AL,1
                  MOV               CL,PROG_R_LEN
                  JMP               PROG_OUT
;
PROG_W:           MOV               BX,OFFSET PROG_W_M
                  MOV               AL,COL_SIZE
                  MOV               AH,PROG_W_LEN
                  SUB               AL,AH
                  SHR               AL,1
                  MOV               CL,PROG_W_LEN
;
PROG_OUT:         MOV               CH,07H
                  MOV               AH,12H
                  CALL              DISP_STRING
;
                  POP               AX
                  OR                AL,AL
                  JZ                READ_TRK_NO
                  DEC               AL
                  JZ                WRITE_TRK_NO
;
VERIFY_TRK_NO:    MOV               AL,TRACK_NO_V
                  JMP               DISP_TRACK
;
READ_TRK_NO:      MOV               AL,TRACK_NO_R
                  JMP               DISP_TRACK
;
WRITE_TRK_NO:     MOV               AL,TRACK_NO_W
;
DISP_TRACK:       CALL              TRACK_OUT
;
                  RET
;
PROG_DISP         ENDP
;
;
PAGE
;
;TRACK_OUT
;
;          DISPLAY THE CURRENT TRACK NUMBER
;
;          AL = CURRENT TRACK NUMBER
;
TRACK_OUT         PROC               NEAR
;
                  XOR                AH,AH
                  XOR                CH,CH
;
                  MOV                CL,0AH
                  DIV                CL
                  PUSH               AX
;
                  CALL               ASCII_OUT
;
                  POP                AX
                  MOV                AL,AH
                  CALL               ASCII_OUT
;
                  RET
;
TRACK_OUT         ENDP
;
;
PAGE
;
;ASCII_OUT
;
;          DISPLAY DECIMAL DIGIT IN IT'S FORM
;          AFTER MOVING THE CURSOR 1 POSTION
;          ON THE SCREEN
;
ASCII_OUT         PROC              NEAR
;
                  PUSH              AX
;
                  MOV               AH,3
                  MOV               BH,ACT_PAGE
                  INT               10H
;
                  MOV               AH,2
                  MOV               BH,ACT_PAGE
                  INC               DX
                  INT               10H
;
                  POP               AX
                  MOV               AH,9
                  MOV               BH,ACT_PAGE
                  MOV               CX,1
                  ADD               AL,30H
                  MOV               BL,07H
                  INT               10H
;
                  RET
;
ASCII_OUT         ENDP
;
CODE_SEG          ENDS
;
                  END




                   

    
