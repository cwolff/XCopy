NAME               SCERR

TITLE              SECTOR_COPY

SUBTTL             ERROR_HANDLING 

PAGE 60,132

;**************************************************************************
;
;                  COPYRIGHT 1982 SOFTWARE LABORATORIES INC.
;                  AUTHOR CALMERON L WOLFF
;
;**************************************************************************

;CODE SEGMENT

CODE_SEG           SEGMENT             PUBLIC 'CODE'

INCLUDE            D:SCDATA.INC

                   EXTRN DISP_STRING:NEAR,CLEAR_WINDOW:NEAR,TRACK_OUT:NEAR
                   PUBLIC ERROR,NOT_READY,NOT_F_B_T
                   PUBLIC WRITE_PROT,BAD_D_IO,YES_NO
                   PUBLIC HEX_OUT

                   ASSUME CS:CODE_SEG

PAGE

; QUICK COPY'S FOUR ASM FILES AND 1 INCLUDE FILE ARE ALL ASSEMBLED
; TO GENERATE FOUR OBJ FILES. THESE FOUR FILES ARE THEN LINKED
; TOGETHER TO RESULT IN ONE EXE FILE. THIS EXE FILE IS THEN CONVERTED
; TO A COM FILE (WHICH LOADS FASTER THAN A EXE FILE) BY EXE2BIN.
; QCDRVR.ASM HAS AN ORG 100H INSTRUCTION. THIS IS NECESSARY IF FOR A
; COM FILE IS TO BE LOADED PROPERLY. ADDITIONAL INFORMATION CAN BE FOUND
; IN THE IBM DOS AND IBM MACRO ASSEMBLER MANUALS.

PAGE

;ERROR
;
;         DISPLAY DISK ERROR (READ WRITE VERIFY)
;         AND QUERRY USER IF THE WISH TO CONTINUE
;
;         AH = ERROR VALUE
;              80 = ATTACHMENT FAILED TO RESPOND
;              40 = SEEK OPERATION FAILED
;              20 = NEC CONTROLLER FAILED
;              10 = BAD CRC ON DISK READ
;              09 = ATTEMPT TO DMA ACROSS 64K BOUNDRY
;              08 = DMA OVERRUN ON OPERATION
;              04 = REQUESTED SECTOR NOT FOUND
;              03 = WRITE ATTEMPTED ON WRITE PROT DISK
;              02 = ADDRESS MARK NOT FOUND
;              01 BAD COMMAND TO DISK I/O
;
;         AL = OPERATION TAKING PLACE DURNING ERROR
;              00 = READ
;              01 = WRITE
;              02 = VERIFY
;              03 = FORMAT
;              04 = MAP

ERROR              PROC              NEAR

                   PUSH              AX
                   CALL              CLEAR_WINDOW

E_FLUSH:           MOV               AH,1
                   INT               16H

                   JZ                E_BUF_CLR
                   MOV               AH,0
                   INT               16H
                   JMP               E_FLUSH

E_BUF_CLR:         POP               AX
                   PUSH              AX

                   CMP               AH,80H
                   JZ                NOT_RDY

                   CMP               AH,40H
                   JZ                BAD_IO
                   CMP               AH,10H
                   JZ                BAD_IO
                   CMP               AH,04H
                   JZ                BAD_IO

                   CMP               AH,03H
                   JZ                WRT_PROT

                   CMP               AH,02H
                   JZ                NOT_F

; THE FOLLOWING CATCHES ANY ERRORS NOT CHECK FOR ABOVE
; AND DISPLAYS THE HEX CODE TO THE SCREEN.

                   CALL              CLEAR_WINDOW

                   MOV               AH,2
                   MOV               DX,1028H
                   MOV               BH,ACT_PAGE
                   INT               10H

                   POP               AX
                   CALL              HEX_OUT

T1:                MOV               AX,0FFFFH
T2:                MOV               CX,10H
T3:                DEC               CX
                   JNZ               T3
                   DEC               AX
                   JNZ               T2

                   JMP               ERROR_F

NOT_RDY:           POP               AX
                   CALL              NOT_READY
                   JMP               ERROR_F

BAD_IO:            POP               AX
                   CALL              BAD_D_IO
                   JMP               ERROR_F

WRT_PROT:          POP               AX
                   CALL              WRITE_PROT
                   JMP               ERROR_F

NOT_F:             POP               AX
                   CALL              NOT_F_B_T

ERROR_F:           PUSHF
                   CALL              CLEAR_WINDOW
                   POPF

                   RET

ERROR              ENDP

PAGE

;NOT_READY
;
;          INFORMS THE USER THAT THE DRIVE IS
;          INOPERABLE AND ASK THEM IF THEY WISH
;          TO CONTINUE
;
;          AL = OERATION THAT IS IN PROGRESS
;               00 = READ
;               01 = WRITE
;               02 = VERIFY
;               03 = FORMAT
;               05 = MAP
;
;          RETURNS:
;          ZERO FLAG = 1 TO CONTINUE
;          ZERO FLAG = 0 TO ABORT

NOT_READY         PROC               NEAR

                  OR                 AL,AL
                  JZ                 NOT_SRCE
                  CMP                AL,5
                  JE                 NOT_SRCE

NOT_DEST:         MOV                AL,COL_SIZE
                  MOV                AH,NOT_DEST_LEN
                  SUB                AL,AH
                  SHR                AL,1
                  MOV                CL,NOT_DEST_LEN
                  MOV                BX,OFFSET NOT_DEST_M
                  JMP                NOT_OUT

NOT_SRCE:         MOV                AL,COL_SIZE
                  MOV                AH,NOT_SRCE_LEN
                  SUB                AL,AH
                  SHR                AL,1
                  MOV                CL,NOT_SRCE_LEN
                  MOV                BX,OFFSET NOT_SRCE_M

NOT_OUT:          MOV                CH,7
                  MOV                AH,10H
                  CALL               DISP_STRING

                  CALL               YES_NO

                  RET

NOT_READY         ENDP

PAGE

;NOT_F_B_T
;
;          INFORMS THE USER THAT THE DISK IS NOT
;          FORMATTED OR OF A POSSIBLE BAD TRACK.
;
;          AL = CURRENT OPERATION
;             AL = 0 READ
;             AL = 1 WRITE
;             AL = 2 VERIFY
;             AL = 3 FORMAT
;             AL = 4 MAP
;
;          RETURNS:
;          ZERO FLAG = 1 TO CONTINUE
;          ZERO FLAG = 0 TO ABORT

NOT_F_B_T         PROC                NEAR

                  OR                  AL,AL
                  JNZ                 N_DEST
                  CMP                 AL,5
                  JNE                 N_DEST

N_SRCE:           MOV                 AL,COL_SIZE
                  MOV                 AH,N_SRCE_LEN
                  SUB                 AL,AH
                  SHR                 AL,1
                  MOV                 CL,N_SRCE_LEN
                  MOV                 BX,OFFSET N_SRCE_M
                  JMP                 N_OUT

N_DEST:           MOV                 AL,COL_SIZE
                  MOV                 AH,N_DEST_LEN
                  SUB                 AL,AH
                  SHR                 AL,1
                  MOV                 CL,N_DEST_LEN
                  MOV                 BX,OFFSET N_DEST_M

N_OUT:            MOV                 CH,07H
                  MOV                 AH,10H
                  CALL                DISP_STRING

                  MOV                 AL,TRACK_NO_R
                  CALL                TRACK_OUT

                  CALL                YES_NO

                  RET

NOT_F_B_T         ENDP

PAGE

;WRITE_PROT
;
;          THIS ROUTINE INFORMS THE USER THAT THIER    
;          DISK IN WRITE PROTECED
;
;          AL = CURRENT OPERATION
;               00 = READ
;               01 = WRITE
;               02 = VERIFY
;
;          RETURNS:
;          ZERO FLAG = 1 CONTINUE
;          ZERO FALG = 0 ABORT

WRITE_PROT        PROC                 NEAR

                   MOV                 AL,COL_SIZE
                   MOV                 AH,WRITE_D_LEN
                   SUB                 AL,AH
                   SHR                 AL,1
                   MOV                 CL,WRITE_D_LEN
                   MOV                 BX,OFFSET WRITE_D_M
                   MOV                 AH,10H
                   MOV                 CH,07H
                   CALL                DISP_STRING

                   CALL                YES_NO

                   RET

WRITE_PROT         ENDP

PAGE

;BAD_D_IO
;
;          INFORMS THE USER THAT A READ OR WRITE OR
;          VERIFY COULD NOT BE PERFORMED BECAUSE OF
;          A DEFECTIVE DISK
;
;          AL = CURRENT OPERATION
;               0 = READ
;               1 = WRITE
;               2 = VERIFY
;               3 = FORMAT
;               5 = MAP
;
;          RETURNS:
;          ZERO FLAG = 1 CONTINUE
;          ZERO FLAG = 0 ABORT

BAD_D_IO          PROC               NEAR

                  CMP                AL,5
                  JE                 BAD_S
                  OR                 AL,AL
                  JZ                 BAD_S
                  DEC                AL
                  JZ                 BAD_D
                  DEC                AL
                  JZ                 BAD_V

BAD_FMT:          MOV                AL,COL_SIZE
                  MOV                AH,BAD_F_LEN
                  SUB                AL,AH
                  SHR                AL,1
                  MOV                CL,BAD_F_LEN
                  MOV                BX,OFFSET BAD_F_M

                  JMP                BAD_OUT

BAD_V:            MOV                AL,COL_SIZE
                  MOV                AH,BAD_V_LEN
                  SUB                AL,AH
                  SHR                AL,1
                  MOV                CL,BAD_V_LEN
                  MOV                BX,OFFSET BAD_V_M

                  JMP                BAD_OUT

BAD_S:            MOV                AL,COL_SIZE
                  MOV                AH,BAD_S_LEN
                  SUB                AL,AH
                  SHR                AL,1
                  MOV                CL,BAD_S_LEN
                  MOV                BX,OFFSET BAD_S_M
              
                  JMP                BAD_OUT

BAD_D:            MOV                AL,COL_SIZE
                  MOV                AH,BAD_D_LEN
                  SUB                AL,AH
                  SHR                AL,1
                  MOV                CL,BAD_D_LEN
                  MOV                BX,OFFSET BAD_D_M

BAD_OUT:          MOV                CH,07H
                  MOV                AH,10H
                  CALL               DISP_STRING

                  MOV                AL,TRACK_NO_R
                  CALL               TRACK_OUT

                  CALL               YES_NO

                  RET

BAD_D_IO          ENDP

PAGE

;YES_NO
;
;         THIS PROCEDURE IS USED TO ASK THE USER IF THEY WISH
;         TO CONTINUE.
;
;          RETURNS:
;          ZERO FLAG = 1 CONTINUE
;          ZERO FALG = 0 ABORT

YES_NO            PROC               NEAR

                  MOV                AL,COL_SIZE
                  MOV                AH,SHORT_LEN
                  SUB                AL,AH
                  SHR                AL,1
                  MOV                CL,SHORT_LEN
                  MOV                BX,OFFSET SHORT_M

YES_OUT:          MOV                CH,07H
                  MOV                AH,12H
                  CALL               DISP_STRING

                  MOV                AL,COL_SIZE
                  MOV                AH,QUE_LEN2
                  SUB                AL,AH
                  SHR                AL,1

                  MOV                AH,14H
                  MOV                CH,07H
                  MOV                CL,QUE_LEN2
                  MOV                BX,OFFSET QUE_MESS2
                  CALL               DISP_STRING

                  MOV                AL,COL_SIZE
                  MOV                AH,QUE_LEN3
                  SUB                AL,AH
                  SHR                AL,1

                  MOV                AH,15H
                  MOV                CH,07H
                  MOV                CL,QUE_LEN3
                  MOV                BX,OFFSET QUE_MESS3
                  CALL               DISP_STRING

G_YN_KEY:         MOV                AH,0
                  INT                16H

                  CMP                AL,59H
                  JZ                 YN_YES
                  CMP                AL,79H
                  JZ                 YN_YES

                  CMP                AL,4EH
                  JZ                 YN_NO
                  CMP                AL,6EH
                  JZ                 YN_NO

                  JMP                G_YN_KEY

YN_YES:           XOR                AX,AX
                  JMP                YN_F

YN_NO:            MOV                AL,1
                  OR                 AL,AL

YN_F:             RET

YES_NO            ENDP

PAGE

;HEX_OUT
;
;           DISPLAYS A TWO DIGIT HEX VALUE TO THE SCREEN.
;
;           AH = TWO DIGIT HEX VALUE TO BE DISPLAYED

HEX_OUT           PROC               NEAR

                  PUSH               AX

                  MOV                AL,AH
                  AND                AL,0F0H
                  MOV                CL,4
                  SHR                AL,CL
                  CALL               DISP_HEX

                  POP                AX

                  MOV                AL,AH
                  AND                AL,0FH
                  CALL               DISP_HEX

                  RET

HEX_OUT           ENDP

PAGE

;DISP_HEX
;
;          AL = HEX VALUE TO BE DISPLAYED

DISP_HEX          PROC               NEAR

                  PUSH               AX

                  MOV                AH,3
                  MOV                BH,ACT_PAGE
                  INT                10H

                  MOV                AH,2
                  INC                DX
                  MOV                BH,ACT_PAGE
                  INT                10H

                  POP                AX

                  CMP                AL,0AH
                  JGE                ALPHA
                  ADD                AL,30H
                  JMP                OUT_HEX

ALPHA:            ADD                AL,37H

OUT_HEX:          MOV                AH,9
                  MOV                CX,1
                  MOV                BH,ACT_PAGE
                  MOV                BL,07H
                  INT                10H

                  RET

DISP_HEX          ENDP

CODE_SEG          ENDS

                  END