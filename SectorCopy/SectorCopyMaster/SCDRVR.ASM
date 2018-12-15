
NAME             SCDRVR
 
TITLE            SECTOR_COPY
 
SUBTTL           DRIVER 
 
PAGE 60,132
 
; *************************************************************************
; |                                                                       |
; |              COPYRIGHT 1982 SOFTWARE LABORATORIES INC.                |
; |              AUTHOR CAMERON L WOLFF                                   |
; |                                                                       |
; *************************************************************************
 
;CODE SEGMENT
 
CODE_SEG         SEGMENT               PUBLIC 'CODE'
 
                 ORG                   100H

 
INCLUDE          D:SCDATA.INC
 
                 EXTRN ERROR:NEAR,START_DISP:NEAR,DR2_DISP:NEAR
                 EXTRN SRCE_DISP:NEAR,DEST_DISP:NEAR,QUERRY_DISP:NEAR
                 EXTRN RETURN:NEAR,DISP_STRING:NEAR,CLEAR_SCRN:NEAR
                 EXTRN CLEAR_WINDOW:NEAR,PROG_DISP:NEAR,TRACK_OUT:NEAR
                 EXTRN ASCII_OUT:NEAR,MAP_DISK:NEAR,DISP_SECTOR:NEAR
 
PAGE
 
;DRIVER
;
;          SYSTEM OVERSEER
;
;          THIS UTILITY COPIES MANY DISKS IN EITHER OPERATING SYSTEM
;          (PC DOS OR CP/M-86) REGARDLESS OF WHAT OPERATING SYSTEM YOU
;          ARE RUNNING UNDER.
          

DRIVER             PROC            FAR

                   ASSUME CS:CODE_SEG

; SET STACK TO TOP OF PROGRAM SEGMENT

                   MOV             SP,100H

; CALCULATE WERE THE DISK TRANFER AREA'S SEGMENT SHOULD START

                   MOV             AX,CS
                   MOV             BX,OFFSET END_DATA
                   MOV             CL,4
                   SHR             BX,CL
                   ADD             BX,1
                   ADD             AX,BX
                   MOV             DTA_SEG,AX

                   CALL            INIT

                   CALL            CURSOR_OFF

                   CALL            CLEAR_SCRN
                   MOV             AX,0
                   CALL            DISPLAY
                   CALL            CLEAR_WINDOW

ANOTHER_D:         MOV             AX,0
                   CALL            PROMPT

                   MOV             DISK_SIDE,0
                   CALL            COPY
                   JZ              CHECK_QUERRY

                   MOV             TRACK_NO_R,0
                   MOV             TRACK_NO_W,0

                   MOV             DISK_SIDE,1
                   CALL            COPY

CHECK_QUERRY:

                   CALL            QUERRY
                   JZ              ANOTHER_D

EXIT:              CALL            CLEAR_SCRN
                   CALL            CURSOR_ON 

                   PUSH            DS

                   MOV             AX,0
                   MOV             DS,AX
                   MOV             BX,78H
                   MOV             AX,0EFC7H
                   MOV             [BX],AX
                   MOV             AX,0F000H
                   MOV             [BX+2],AX

                   POP             DS

; INT 20 RETURNS YOU TO THE OPERATING SYSTEM FROM A 'COM' PROGRAM.

                   INT             20H

DRIVER             ENDP

PAGE

;INIT
;                                 
;          INITIALIZE VARIABLES AND DETERMINE THE SYSTEM
;          CONFIGURATION (MEMORY SIZE, SIZE OF DISPLAY, NO. OF DISKS)

INIT               PROC             NEAR

                   INT              11H
                   MOV              SYSCONFIG,AX
                   AND              AX,0C0H
                   MOV              CL,6
                   SHR              AX,CL
                   OR               AL,AL
                   JZ               JUST_ONE
    
TWO_DRIVE:         MOV              AL,1
                   MOV              NODR,AL
                   MOV              DEST,AL
                   MOV              AL,0
                   MOV              SRCE,AL
                   JMP              VIDEO_CONF

JUST_ONE:          MOV              AL,0
                   MOV              NODR,AL
                   MOV              DEST,AL
                   MOV              SRCE,AL

; INTIALIZE VARIABLES THEN DETERMINE NO. OF COLUMNS OF VIDEO.

VIDEO_CONF:        MOV              AX,0
                   MOV              TRACK_NO_R,AL
                   MOV              TRACK_NO_W,AL

                   MOV              AH,0FH
                   INT              10H
                   MOV              MODE,AL
                   MOV              COL_SIZE,AH
                   MOV              ACT_PAGE,BH

; DETERMINE MEMORY SIZE TO DETERMINE HOW MANY TRACKS CAN BE READ
; INTO MEMORY AT ONCE.

MEMORY_CONF:       INT              12H

                   MOV              BL,28H
                   CMP              AX,0C0H
                   JGE              LOAD_SIZE

                   MOV              BL,14H
                   CMP              AX,60H
                   JGE              LOAD_SIZE

                   MOV              BL,0AH
                   CMP              AX,40H
                   JGE              LOAD_SIZE

                   MOV              BL,08H
                   CMP              AX,30H
                   JGE              LOAD_SIZE

                   MOV              BL,05H

LOAD_SIZE:         MOV              MEMORY_SIZE,BL

                   RET

INIT               ENDP

PAGE

;CURSOR_OFF
;
;          TURN CURSOR OFF.

CURSOR_OFF         PROC              NEAR

                   MOV               AH,1
                   MOV               CX,3030H
                   INT               10H

                   RET

CURSOR_OFF         ENDP

PAGE

;CURSOR_ON 
;
;          TURN CURSOR BACK ON.
 
CURSOR_ON          PROC            NEAR

                   MOV             AH,1
                   MOV             CX,0607H
                   INT             10H

                   RET

CURSOR_ON          ENDP

PAGE

;DISPLAY
;
;          AX = 0 DISPLAY STARTING PROMPT
;          AX = 1 DISPLAY TWO DRIVE PROMPT
;          AX = 2 DISPLAY SOURCE PROMPT
;          AX = 3 DISPLAY DESTINATION PROMPT

DISPLAY           PROC              NEAR

                  PUSH              AX

; FLUSH BUFFER SO THERE WON'T BE ANY UNWANTED RESPONSES BEFORE
; THE APPROPRIATE PROMPT IS DISPLAYED

FLUSH:            MOV               AH,1
                  INT               16H
                  JZ                BUF_CLR

                  MOV               AH,0
                  INT               16H
                  JMP               FLUSH

BUF_CLR:          POP               AX
                  OR                AX,AX
                  JNZ               D1
                  CALL              START_DISP
                  JMP               DIS_DONE

D1:               DEC               AX
                  JNZ               D2
                  CALL              DR2_DISP
                  JMP               DIS_DONE

D2:               DEC               AX
                  JNZ               D3
                  CALL              SRCE_DISP
                  JMP               DIS_DONE

D3:               DEC               AX
                  JNZ               D4
                  CALL              DEST_DISP
                  JMP               DIS_DONE

D4:               DEC               AX
                  JNZ               DIS_DONE
                  CALL              QUERRY_DISP

DIS_DONE:         RET

DISPLAY           ENDP

PAGE

;PROMPT
;
;          AX = 0 PROMPT START
;          AX = 1 PROMPTS READ
;          AX = 2 PROMPT WRITE

PROMPT            PROC              NEAR

                  OR                AX,AX
                  JZ                START_P
                  DEC               AX
                  JZ                READ_P

WRITE_P:          MOV               AL,NODR
                  OR                AL,AL
                  JNZ               END_P
                  MOV               AX,3
                  CALL              DISPLAY
                  JMP               END_P

READ_P:           MOV               AL,NODR
                  OR                AL,AL
                  JNZ               END_P
                  MOV               AL,TRACK_NO_R
                  CMP               AL,28H
                  JGE               END_P
                  MOV               AX,2
                  CALL              DISPLAY
                  JMP               END_P

START_P:          MOV               AL,NODR
                  OR                AL,AL
                  JZ                ONE_D
                  MOV               AX,1
                  CALL              DISPLAY
                  JMP               END_P

ONE_D:            MOV               AX,2
                  CALL              DISPLAY

END_P:            PUSHF
                  CALL              CLEAR_WINDOW
                  POPF

                  RET

PROMPT            ENDP

PAGE

;COPY
;
;          MAPS ONE TRACK FORMATS ONE TRACK READS ONE TRACK
;          AND WRITES ONE TRACK AT A TIME

COPY              PROC              NEAR

; RESET THE DISK DRIVES TO PREPARE THEM FOR THE COPY.

                  MOV               AH,0
                  INT               13H

                  MOV               LAST_TYPE,2

CALL_MAP_DISK:

                  CALL              MAP_DISK
                  JZ                COPY_CONT
                  XOR               AH,AH
                  JMP               EOD

        COPY_CONT:

                  CMP               NUMBER_OF_FOUND_SECTORS,0
                  JNE               CALL_DISK_READ

                  INC               TRACK_NO_R
                  INC               TRACK_NO_W

                  CMP               TRACK_NO_R,40
                  JNE               CALL_MAP_DISK
                  JMP               EOD

CALL_DISK_READ:

                  MOV               AX,DTA_SEG
                  MOV               ES,AX

                  CALL              DREAD
                  JZ                EOD

                  MOV               AX,2
                  CALL              PROMPT

                  PUSH              CS
                  POP               ES          ; SET ES TO FORMAT PARA. SEG

                  CALL              DFORMAT
                  JZ                EOD

                  MOV               AX,DTA_SEG
                  MOV               ES,AX

                  CALL              DWRITE
                  JZ                EOD

                  CALL              DVERIFY
                  JZ                EOD

; CHECK IF DONE

                  INC               TRACK_NO_R
                  CMP               TRACK_NO_R,40
                  JZ                EOD

                  INC               TRACK_NO_W


                  MOV               AX,1
                  CALL              PROMPT
                  JMP               CALL_MAP_DISK

EOD:              RET

COPY              ENDP

PAGE

;QUERRY
;
;          ASK IF ANOTHER COPY IS TO BE MADE.
;
;          RETURNS:
;          ZERO FLAG = 1 IF YES
;          ZERO FLAG = 0 IF NO

QUERRY            PROC               NEAR

                  MOV                AX,4
                  CALL               DISPLAY

GET_KEY:          MOV                AH,0
                  INT                16H

                  CMP                AL,59H
                  JZ                 YES
                  CMP                AL,79H
                  JZ                 YES

                  CMP                AL,4EH
                  JZ                 NO
                  CMP                AL,6EH
                  JZ                 NO

                  JMP                GET_KEY

YES:              MOV                AX,0
                  MOV                TRACK_NO_R,AL
                  MOV                TRACK_NO_W,AL

                  OR                 AX,AX
                  JMP                Q_DONE

NO:               MOV                AX,1
                  OR                 AX,AX

Q_DONE:           PUSHF
                  CALL               CLEAR_WINDOW
                  POPF

                  RET

QUERRY            ENDP

PAGE

;DREAD
;
;          READS THE DISKETTE TRACK FOR TRACK UNTIL MEMORY IS FILLED
;          OR THE END OF THE DISK IS REACHED.
;
;          RETURNS:
;             ZERO FLAG = 0 IF MORE TO READ
;             ZERO FLAG = 1 IF THERE ARE NO MORE TRACKS TO READ.

DREAD             PROC               NEAR

                  MOV                AL,NUMBER_OF_FOUND_SECTORS
                  MOV                SECTOR_COUNTER,AL
                  MOV                SI,OFFSET FORMAT_BLOCK
                  ADD                SI,2

DRD_LOOP:         MOV                AL,0
                  CALL               PROG_DISP

                  MOV                AL,CS:[SI]
                  CALL               DISP_SECTOR

                  MOV                RETRY,06H

BREAD:            MOV                AH,02H
                  MOV                DH,DISK_SIDE
                  MOV                DL,SRCE
                  MOV                CH,TRACK_NO_R
                  MOV                CL,CS:[SI]
                  MOV                AL,1
                  MOV                BX,00H
                  INT                13H

                  OR                 AH,AH
                  JZ                 GREAD

; THERE WAS AN ERROR READING THE DISKETTE EXAMINE THE AH REGISTER
; TO SEE IF THE ERROR WAS AN ATTEMPT TO CROSS A 64K BOUNDRY.

                  CMP                AH,09H
                  JZ                 RDMA

                  PUSH               AX
                  MOV                AH,0
                  INT                13H
                  POP                AX
                  JMP                RERROR

; THERE WAS AN ATTEMPT TO READ DATA FROM THE DISKETTE AND PLACE IT
; IN MEMORY WERE IT WOULD CROSS A 64K BOUNDRY. INCREMENT THE ES
; BY SECTOR SIZE SO AS TO ADDRESS
; MEMORY ON THE UPPER SIDE OF THE 64K BOUNDRY. THIS WILL ALLOW US
; TO CONTINUE READING THE DISKETTE INTO MEMORY.

RDMA:

                  MOV                BX,ES
                  ADD                BX,SECTOR_SIZE
                  MOV                ES,BX

RERROR:           DEC                RETRY
                  JNZ                BREAD

; THE SIX RETRIES HAVE FAILED CALL ERROR (IN QCERR) TO INFORM THE
; USER AS TO THE PROBLEM.

                  CMP                AH,10H
                  JE                 GREAD     ; STEP PAST CRC SECTOR

                  PUSH               AX

                  MOV                AL,0
                  CALL               ERROR

                  POP                AX

                  JZ                 R_CHECK_ACTION_TO_TAKE
                  XOR                AX,AX
                  JMP                R_DONE_F

; CHECK ACTION TO TAKE

        R_CHECK_ACTION_TO_TAKE:

                  CMP               AH,04H
                  JZ                GREAD

                  JMP               DRD_LOOP

; A GOOD READ HAS BEEN COMPLETED. INCREMENT THE NECESSARY VARIABLES
; TO READ THE NEXT TRACK.

GREAD:            MOV                BX,ES
                  ADD                BX,SECTOR_SIZE
                  MOV                ES,BX
                  ADD                SI,4
                  DEC                SECTOR_COUNTER
                  JNZ                DRD_LOOP

R_DONE:           MOV                AX,1
                  OR                 AX,AX

R_DONE_F:         PUSHF
                  CALL               CLEAR_WINDOW
                  POPF

                  RET

DREAD             ENDP

PAGE

;DWRITE
;
;          WRITES TO THE DISKETTE. THIS PROCEDURE IS VERY SIMILIAR
;          DREAD. THE COMMENTS IN DREAD WILL HELP IN UNDERSTANDING
;          DWRITE.

DWRITE            PROC               NEAR

                  MOV                AL,NUMBER_OF_FOUND_SECTORS
                  MOV                SECTOR_COUNTER,AL
                  MOV                SI,OFFSET FORMAT_BLOCK
                  ADD                SI,2

DWT_LOOP:         MOV                AL,1
                  CALL               PROG_DISP

                  MOV                AL,CS:[SI]
                  CALL               DISP_SECTOR

                  MOV                RETRY,6

BWRITE:           MOV                AH,3
                  MOV                DH,DISK_SIDE
                  MOV                DL,DEST
                  MOV                CH,TRACK_NO_W
                  MOV                CL,CS:[SI]
                  MOV                AL,1
                  MOV                BX,00H
                  INT                13H

                  OR                 AH,AH
                  JZ                 GWRITE

                  CMP                AH,09H
                  JZ                 WDMA

                  PUSH               AX
                  MOV                AH,0
                  INT                13H
                  POP                AX
                  JMP                WERROR

WDMA:             MOV                BX,ES
                  ADD                BX,SECTOR_SIZE
                  MOV                ES,BX

WERROR:           DEC                RETRY
                  JNZ                BWRITE

                  MOV                AL,1
                  CALL               ERROR

                  JZ                 W_CHECK_IF_DONE
                  XOR                AX,AX
                  JMP                W_DONE_F

GWRITE:           MOV                BX,ES
                  ADD                BX,SECTOR_SIZE
                  MOV                ES,BX
                  ADD                SI,4

W_CHECK_IF_DONE:

                  DEC                SECTOR_COUNTER
                  JNZ                DWT_LOOP

W_DONE:           MOV                AX,1
                  OR                 AX,AX

W_DONE_F:         PUSHF
                  CALL               CLEAR_WINDOW
                  POPF

                  RET

DWRITE            ENDP

PAGE

;DVERIFY

;          VERIFIES THE WRITES TO THE DISKETTE. LIKE DWRITE THIS PROCEDURE
;          IS VERY SIMILIAR TO DREAD. THE COMMENTS IN DREAD WILL HELP IN
;          UNDERSTANDING DVERIFY.

DVERIFY           PROC                NEAR

                  MOV                 AL,NUMBER_OF_FOUND_SECTORS
                  MOV                 SECTOR_COUNTER,AL
                  MOV                 SI,OFFSET FORMAT_BLOCK
                  ADD                 SI,2

DV_LOOP:
                  MOV                 AL,2
                  CALL                PROG_DISP

                  MOV                 AL,CS:[SI]
                  CALL                DISP_SECTOR

                  MOV                 RETRY,6

BVERIFY:
                  MOV                 AH,4
                  MOV                 DH,DISK_SIDE
                  MOV                 DL,DEST
                  MOV                 CH,TRACK_NO_W
                  MOV                 CL,CS:[SI]
                  MOV                 AL,1
                  MOV                 BX,00H
                  INT                 13H

                  OR                  AH,AH
                  JZ                  GVERIFY

                  CMP                 AH,09H
                  JZ                  VDMA

                  PUSH                AX
                  MOV                 AH,0
                  INT                 13H
                  POP                 AX
                  JMP                 VERROR

VDMA:             MOV                 BX,ES
                  ADD                 BX,100H
                  MOV                 ES,BX

VERROR:           DEC                 RETRY
                  JNZ                 BVERIFY

                  MOV                 AL,2
                  CALL                ERROR

                  JZ                  V_CHECK_IF_DONE
                  XOR                 AX,AX
                  JMP                 V_DONE_F

GVERIFY:          MOV                 BX,ES
                  ADD                 BX,SECTOR_SIZE
                  MOV                 ES,BX
                  ADD                 SI,4

V_CHECK_IF_DONE:

                  DEC                 SECTOR_COUNTER
                  JNZ                 DV_LOOP

V_DONE:           MOV                 AX,1
                  OR                  AX,AX

V_DONE_F:         PUSHF
                  CALL                CLEAR_WINDOW
                  POPF

                  RET

DVERIFY           ENDP

PAGE

;DFORMAT
;
;          FORMATS THE DISKETTE.
;

DFORMAT           PROC               NEAR

                  MOV                RETRY,6
                  MOV                AL,3
                  CALL               PROG_DISP

; START UP DRIVE WITH A VERIFY

                  MOV                AH,4
                  MOV                AL,1
                  MOV                CH,TRACK_NO_W
                  MOV                CL,1
                  MOV                DH,DISK_SIDE
                  MOV                DL,DEST
                  INT                13H

                  MOV                AL,NUMBER_OF_FOUND_SECTORS
                  MOV                SECTOR_COUNTER,AL
                  MOV                SI,OFFSET FORMAT_BLOCK
                  ADD                SI,2

DFT_LOOP:
                  MOV                RETRY,6
                  MOV                AL,3
                  CALL               PROG_DISP

; BX POINTS TO DISK FORMAT PARAMETERS

BFORMAT:
                  MOV                AH,5
                  MOV                DH,DISK_SIDE
                  MOV                DL,DEST
                  MOV                CH,TRACK_NO_W
                  MOV                CL,1
                  MOV                AL,NUMBER_OF_FOUND_SECTORS
                  MOV                BX,OFFSET FORMAT_BLOCK
                  INT                13H

                  OR                 AH,AH
                  JZ                 F_DONE_F

                  PUSH               AX
                  MOV                AH,0
                  INT                13H
                  POP                AX

                  DEC                RETRY
                  JNZ                BFORMAT

                  MOV                AL,3
                  CALL               ERROR

                  JZ                 DFT_LOOP
                  XOR                AX,AX
                  JMP                F_RETURN

F_DONE_F:
                  OR                 AL,1

F_RETURN:
                  PUSHF
                  CALL               CLEAR_WINDOW
                  POPF

                  RET

DFORMAT           ENDP

CODE_SEG          ENDS

                  END                 DRIVER

