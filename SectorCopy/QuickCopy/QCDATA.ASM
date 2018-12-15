NAME               QCDATA
;
SUBTTL             DATA
;
PAGE 60,132
;
;***************************************************************************
;
;                  COPYRIGHT 1982 SOFTWARE LABORATORIES INC
;                  AUTHOR CAMERON L WOLFF
;
;***************************************************************************
;
;CODE SEGMENT
;
CODE_SEG           SEGMENT          PUBLIC 'CODE'
;
                   PUBLIC SYSCONFIG,NODR,DEST,SRCE,TRACK_NO_R
                   PUBLIC TRACK_NO_W,TRACK_NO_V,COL_SIZE,ACT_PAGE
                   PUBLIC MODE,ROWCOL,ATTR,C_PTR,DISK_CNT,RETRY
                   PUBLIC QC_MESS,QC_LEN,DEV_MESS,DEV_LEN,DR2_MESS1,DR2_LEN1
                   PUBLIC DR2_MESS2,DR2_LEN2,RET_MESS,RET_LEN,SRCE_MESS
                   PUBLIC SRCE_LEN,DEST_MESS,DEST_LEN,QUE_MESS1,QUE_LEN1
                   PUBLIC QUE_MESS2,QUE_LEN2,QUE_MESS3,QUE_LEN3,PROG_W_M
                   PUBLIC PROG_W_LEN,PROG_R_M,PROG_R_LEN,PROG_V_M,PROG_V_LEN
                   PUBLIC NOT_DEST_M,NOT_DEST_LEN,NOT_SRCE_M,NOT_SRCE_LEN
                   PUBLIC N_SRCE_M,N_SRCE_LEN,N_DEST_M,N_DEST_LEN,WRITE_D_M
                   PUBLIC W_D_M,WRITE_D_LEN,BAD_S_M,BAD_S_LEN,BAD_D_M,B_D_M
                   PUBLIC BAD_D_LEN,BAD_V_M,B_V_M,BAD_V_LEN,SHORT_M,SHORT_LEN
                   PUBLIC DTA_SEG,END_DATA,MEMORY_SIZE
;
PAGE
;
;PROGRAM STORAGE
;
;          VARIABLES TO BE USED BY QUICK COPY
;
SYSCONFIG          DW       00H ;CONTAINS THE AX REGISTER FROM INT 11H.
NODR               DB       00H ;CONTAINS THE NUMBER OF FLOPPY DRIVES.
DEST               DB       00H ;CONTAINS THE DESTINATION DRIVE.
SRCE               DB       00H ;CONTAINS THE SOURCE DRIVE.
TRACK_NO_R         DB       00H ;KEEPS TRACK OF THE LAST TRACK READ.
TRACK_NO_W         DB       00H ;KEEPS TRACK OF THE LAST TRACK WRITTEN.
TRACK_NO_V         DB       00H ;KEEPS TRACK OF THE LAST TRACK VERIFIED.
COL_SIZE           DB       00H ;NUMBER OF COLUMNS ON THE VIDEO.
ACT_PAGE           DB       00H ;CURRENT ACTIVE PAGE USED BY THE VIDEO.
MODE               DB       00H ;VIDEO MODE.
ROWCOL             DW       00H ;CONTAINS THE ROW AND COLUMN OF MESSAGES.
ATTR               DB       00H ;ATTRIBUTE (FORGROUND BACKGROUND) OF VIDEO.
C_PTR              DW       00H ;CURRENT CURSOR POSTION.
DISK_CNT           DB       00H ;DETERMINES THE NUMBER OF DISK R W AND V.
RETRY              DW       00H ;NUMBER OF RETRIES ON DISK ERRORS.
DTA_SEG            DW       00H ;CONTAINS DISK TRANSFER AREA SEGMENT VALUE.
MEMORY_SIZE        DB       00H ;USED TO DETERMINE NO. OF TRACKS TO READ.
;
PAGE
;
;SCREEN MESSAGES
;
;          MESSAGES DISPLAYED TO THE SCREEN. EACH MESSAGE STRING
;          IS FOLLOWED BY IT'S LENGTH. 
;
QC_MESS            DB       ' QUICK COPY '
QC_LEN             DB       0CH
;
DEV_MESS           DB       ' COPYRIGHT 1982  SOFTWARE LABORATORIES INC. '
DEV_LEN            DB       2CH
;
DR2_MESS1          DB       'INSERT SOURCE DISKETTE IN DRIVE A'
DR2_LEN1           DB       21H
;
DR2_MESS2          DB       'INSERT DESTINATION DISKETTE IN DRIVE B'
DR2_LEN2           DB       26H
;
RET_MESS           DB       'HIT RETURN WHEN READY'
RET_LEN            DB       15H
;
SRCE_MESS          DB       'INSERT DISKETTE A (SOURCE)'
SRCE_LEN           DB       1AH
;
DEST_MESS          DB       'INSERT DISKETTE B (DESTINATION)'
DEST_LEN           DB       1FH
;
QUE_MESS1          DB       'DO YOU WISH TO MAKE ANOTHER COPY?'
QUE_LEN1           DB       21H
;
QUE_MESS2          DB       'YES TYPE  Y'
QUE_LEN2           DB       0BH
;
QUE_MESS3          DB       'NO TYPE  N'
QUE_LEN3           DB       0AH
;
PROG_W_M           DB       'WRITING TRACK NUMBER '
PROG_W_LEN         DB       15H
;
PROG_R_M           DB       'READING TRACK NUMBER '
PROG_R_LEN         DB       15H
;
PROG_V_M           DB       'VERIFYING TRACK NUMBER '
PROG_V_LEN         DB       17H
;
NOT_DEST_M         DB       'DESTINATION DRIVE NOT READY --- CORRECT PROBLEM'
NOT_DEST_LEN       DB       2FH
;
NOT_SRCE_M         DB       'SOURCE DRIVE NOT READY --- CORRECT PROBLEM'
NOT_SRCE_LEN       DB       2AH
;
N_SRCE_M           DB       'SOURCE DISKETTE NOT FORMATTED OR BAD TRACK'
N_SRCE_LEN         DB       2AH
;
N_DEST_M           DB       'DESTINATION DISKETTE NOT FORMATTED OR BAD TRACK'
N_DEST_LEN         DB       2FH
;
WRITE_D_M          DB       'DESTINATION DISKETTE IS WRITE PROTECTED '
W_D_M              DB       '--- CORRECT PROBLEM'
WRITE_D_LEN        DB       3BH
;
BAD_S_M            DB       'UNABLE TO READ SOURCE DISKETTE"S TRACK NUMBER '
BAD_S_LEN          DB       2EH
;
BAD_D_M            DB       'UNABLE TO WRITE DESTINATION DISKETTE"S '
B_D_M              DB       'TRACK NUMBER '
BAD_D_LEN          DB       34H
;
BAD_V_M            DB       'VERIFIED FAILED ON DESTINATION DISKETTE"S '
B_V_M              DB       'TRACK NUMBER '
BAD_V_LEN          DB       37H
;
SHORT_M            DB       'DO YOU WISH TO CONTINUE?'
SHORT_LEN          DB       18H
;
; COPYRIGHT AND AUTHOR NOTATION.
;
COPYRIGHT          DB       'COPYRIGHT 1982 SOFTWARE LABORATORIES INC.'
AUTHOR             DB       'AUTHOR CAMERON L. WOLFF'
;
END_DATA           DB       00H
;
CODE_SEG           ENDS
;
                   END