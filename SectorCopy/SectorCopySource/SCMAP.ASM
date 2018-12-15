Name           SCMAP

Title          Sector_copy

Subttl         Sector_map

               Public  map_disk

Page 60,132

CODE_SEG       SEGMENT PUBLIC 'CODE'

               INCLUDE D:SCDATA.INC

               EXTRN PROG_DISP:NEAR,CLEAR_WINDOW:NEAR,ERROR:NEAR
               EXTRN DISP_FOUND_SECTOR:NEAR,DISP_SEARCH_SECTOR:NEAR
               EXTRN TRACK_NOT_FORMATTED:NEAR,DISP_FORMAT_TYPE:NEAR
               EXTRN DISP_STRING:NEAR,RETURN:NEAR

; =========================================================================
; |                                                                       |
; |                           MAP DISK                                    |
; |                                                                       |
; |                   Maps the source diskette in order                   |
; |                   to format the destination diskette                  |
; |                   in the same fashion.                                |
; |                                                                       |
; =========================================================================

                ASSUME  CS:CODE_SEG

MAP_DISK        PROC    NEAR

                MOV     LAST_COUNT,0
                MOV     NUMBER_OF_FOUND_SECTORS,0
                MOV     FOUND_SECTOR_NUMBER,0

                MOV     AL,4
                CALL    PROG_DISP

; CHECK TO SEE IF SECTOR IS EVEN FORMATED

                MOV     RETRY,3
                MOV     SEARCH_SECTOR_NUMBER,1
                CALL    CHECK_FORMAT

                JZ      TEST_FOR_FORMAT    
                JMP     MAP_DISK_RETURN    ; USER SAID DONT CONTINUE

        TEST_FOR_FORMAT:

                CMP     AH,02H
                JNE     TRACK_FORMATTED

                CALL    TRACK_NOT_FORMATTED

                JMP     MAP_DISK_RETURN

; TRY 512 BYTES FOR SECTOR FIRST THEN 1024 256 128

        TRACK_FORMATTED:

                MOV     TYPE_STATUS,0
                MOV     AL,LAST_TYPE
                MOV     FORMAT_TYPE,AL
                CALL    SET_BLOCK

                MOV     SEARCH_SECTOR_NUMBER,0
 
                MOV     BX,OFFSET FORMAT_BLOCK
                MOV     RETRY,3

        NEXT_SECTOR:

                CALL    DISP_MAP_SCREEN

                CALL    CHECK_FORMAT

                JZ      TEST_FOR_SECTOR

                JMP     MAP_DISK_RETURN

        TEST_FOR_SECTOR:

                CMP     AH,0
                JE      VALID_SECTOR

                CMP     AH,10H
                JE      CALL_CRC_PROTECTION

                JMP     INVALID_ADDRESS

; CRC DISPLAY WARNING AND TREAT AS A FOUND SECTOR

        CALL_CRC_PROTECTION:

                INC     NUMBER_OF_FOUND_SECTORS
                MOV     AL,SEARCH_SECTOR_NUMBER
                MOV     FOUND_SECTOR_NUMBER,AL

                CALL    DISP_MAP_SCREEN

                CALL    CRC_PROTECTION

                JMP     UPDATE_FORMAT_BLOCK

; VALID SECTOR DISPLAY IT

        VALID_SECTOR:

                INC     NUMBER_OF_FOUND_SECTORS
                MOV     AL,SEARCH_SECTOR_NUMBER
                MOV     FOUND_SECTOR_NUMBER,AL

                CALL    DISP_MAP_SCREEN

; UPDATE FORMAT BLOCK

        UPDATE_FORMAT_BLOCK:

                MOV     AL,TRACK_NO_R
                MOV     CS:[BX],AL
                INC     BX
                MOV     AL,DISK_SIDE
                MOV     CS:[BX],AL
                INC     BX
                MOV     AL,FOUND_SECTOR_NUMBER
                MOV     CS:[BX],AL
                INC     BX
                MOV     AL,FORMAT_TYPE
                MOV     CS:[BX],AL
                INC     BX

; POINT TO NEXT SECTOR

                INC     SEARCH_SECTOR_NUMBER
                MOV     RETRY,3
 
; HAVE WE FOUND THE MAIXIMUN NUMBER OF GOOD SECTORS

                MOV     AL,MAX_NUMBER_OF_FOUND_SECTORS
                CMP     AL,NUMBER_OF_FOUND_SECTORS
                JBE     MAP_ALL_DONE

; HAVE WE LOOKED AT ALL THE SECTORS

                CMP     SEARCH_SECTOR_NUMBER,0
                JE      MAP_ALL_DONE                 

                JMP     NEXT_SECTOR

        MAP_ALL_DONE:

                XOR     AL,AL
                JMP     MAP_DISK_RETURN

        INVALID_ADDRESS:

                MOV     RETRY,1
                INC     SEARCH_SECTOR_NUMBER
                CMP     SEARCH_SECTOR_NUMBER,0
                JE      CHECK_IF_DONE

                JMP     NEXT_SECTOR

        CHECK_IF_DONE:

                CMP     NUMBER_OF_FOUND_SECTORS,0
                JE      TRY_ANOTHER_BLOCK

                XOR     AL,AL
                JMP     MAP_DISK_RETURN    ; SECTORS PRESENT EXIT

        TRY_ANOTHER_BLOCK:

                CALL    CHECK_STATUS

                JZ      NEXT_BLOCK

                MOV     NUMBER_OF_FOUND_SECTORS,0    ; NO SECTORS FOUND
                XOR     AL,AL
                MOV     LAST_TYPE,2
                JMP     MAP_DISK_RETURN

        NEXT_BLOCK:

                CALL    SET_BLOCK
                MOV     SEARCH_SECTOR_NUMBER,0
                JMP     NEXT_SECTOR

        MAP_DISK_RETURN:

                PUSHF

                CALL    CLEAR_WINDOW

                POPF

                RET

MAP_DISK        ENDP

SUBTTL          CHECK_FORMAT

PAGE

; -------------------------------------------------------------------------
; |                                                                       |
; |                           CHECK FORMAT                                |
; |                                                                       |
; |                   CHECK IF PARTICULAR FORMAT IS VALID                 |
; |                                                                       |
; -------------------------------------------------------------------------

CHECK_FORMAT   PROC     NEAR

               PUSH     BX
               PUSH     CX
               PUSH     DX

        VERIFY_RETRY:

               MOV      AH,4
               MOV      AL,1
               MOV      CH,TRACK_NO_R
               MOV      CL,SEARCH_SECTOR_NUMBER
               MOV      DH,DISK_SIDE
               MOV      DL,SRCE
               INT      13H

               CMP      AH,00H
               JNE      CHECK_FOR_FORMAT

               JMP      CHECK_FORMAT_CONT

        CHECK_FOR_FORMAT:

               CMP      AH,02H
               JNE      CHECK_FOR_ADDRESS

               JMP      CHECK_FORMAT_CONT

        CHECK_FOR_ADDRESS:

               CMP      AH,04H
               JNE      CHECK_FOR_CRC

               JMP      CHECK_FORMAT_CONT

        CHECK_FOR_CRC:

               CMP      AH,10H
               JNE      RETRY_OPERATION

               JMP      CHECK_FORMAT_CONT

        RETRY_OPERATION:

               DEC      RETRY
               JNZ      VERIFY_RETRY

               MOV      AL,5
               CALL     ERROR
               JZ       REFRESH_SCREEN

               JMP      CHECK_FORMAT_RETURN

        REFRESH_SCREEN:

               MOV      AH,0
               INT      13H

               MOV      RETRY,3

               CALL     DISP_MAP_SCREEN

               JMP      VERIFY_RETRY

        CHECK_FORMAT_CONT:

               XOR      AL,AL

        CHECK_FORMAT_RETURN:

               POP      DX
               POP      CX
               POP      BX

               RET

CHECK_FORMAT   ENDP

SUBTTL         SET_BLOCK

PAGE

; -------------------------------------------------------------------------
; |                                                                       |
; |                               SET BLOCK                               |
; |                                                                       |
; |            SET PARAMETER BLOCK TO THE ADDRESS SPECIFIED BY            |
; |                              FORMAT_TYPE                              |
; |                                                                       |
; -------------------------------------------------------------------------

SET_BLOCK      PROC     NEAR

               PUSH     AX
               PUSH     BX
               PUSH     CX
               PUSH     DX

               MOV      AL,FORMAT_TYPE
               CMP      AL,2
               JNE      CHECK_FORMAT_3

               MOV      BX,OFFSET PARAMETER_512
               MOV      PARAMETER_ADDRESS,BX
               OR       TYPE_STATUS,00000100B
               MOV      SECTOR_SIZE,20H
               MOV      MAX_NUMBER_OF_FOUND_SECTORS,8
               MOV      LAST_TYPE,2
               JMP      SET_VECTOR

        CHECK_FORMAT_3:

               CMP      AL,3
               JNE      CHECK_FORMAT_1

               MOV      BX,OFFSET PARAMETER_1024
               MOV      PARAMETER_ADDRESS,BX
               OR       TYPE_STATUS,00001000B
               MOV      SECTOR_SIZE,40H
               MOV      MAX_NUMBER_OF_FOUND_SECTORS,4
               MOV      LAST_TYPE,3
               JMP      SET_VECTOR

        CHECK_FORMAT_1:

               CMP      AL,1
               JNE      CHECK_FORMAT_0

               MOV      BX,OFFSET PARAMETER_256
               MOV      PARAMETER_ADDRESS,BX
               OR       TYPE_STATUS,00000010B
               MOV      SECTOR_SIZE,10H
               MOV      MAX_NUMBER_OF_FOUND_SECTORS,14
               MOV      LAST_TYPE,1
               JMP      SET_VECTOR

        CHECK_FORMAT_0:

               MOV      BX,OFFSET PARAMETER_128
               MOV      PARAMETER_ADDRESS,BX
               OR       TYPE_STATUS,00000001B
               MOV      SECTOR_SIZE,08H
               MOV      MAX_NUMBER_OF_FOUND_SECTORS,32
               MOV      LAST_TYPE,0

         SET_VECTOR:

               PUSH     DS

               MOV      AX,0
               MOV      DS,AX

               MOV      DI,78H
               MOV      [DI],BX
               MOV      [DI+2],CS

               POP      DS

; DISPLAY FORMAT TYPE MESSAGE

               MOV      BX,PARAMETER_ADDRESS
               CALL     DISP_FORMAT_TYPE

               POP      DX
               POP      CX
               POP      BX
               POP      AX

               RET

SET_BLOCK      ENDP

SUBTTL         CHECK_STATUS

PAGE

; -------------------------------------------------------------------------
; |                                                                       |
; |                             CHECK STATUS                              |
; |                                                                       |
; |                    CHECK IF ANOTHER DISK FORMAT NEEDS                 |
; |                         TO BE SERACHED FOR                            |
; |                                                                       |
; -------------------------------------------------------------------------

CHECK_STATUS    PROC    NEAR

                PUSH    AX
                PUSH    BX
                PUSH    CX
                PUSH    DX

                CMP     TYPE_STATUS,00001111B ; HAS EVERY FMT BEEN CHECKED
                JNE     GET_NEXT_FORMAT

                OR      AL,1
                JMP     CHECK_STATUS_RETURN   ; ALL FORMATS HAVE BEEN TRIED

        GET_NEXT_FORMAT:

                TEST    TYPE_STATUS,00000100B
                JNZ     CHECK_TYPE_3

                MOV     FORMAT_TYPE,2
                JMP     CHECK_STATUS_FOUND

        CHECK_TYPE_3:

                TEST    TYPE_STATUS,00001000B
                JNZ     CHECK_TYPE_1

                MOV     FORMAT_TYPE,3
                JMP     CHECK_STATUS_FOUND

        CHECK_TYPE_1:

                TEST    TYPE_STATUS,00000010B
                JNZ     CHECK_TYPE_0

                MOV     FORMAT_TYPE,1
                JMP     CHECK_STATUS_FOUND

        CHECK_TYPE_0:

                MOV     FORMAT_TYPE,0

        CHECK_STATUS_FOUND:

                XOR     AL,AL

        CHECK_STATUS_RETURN:

               POP      DX
               POP      CX
               POP      BX
               POP      AX

               RET

CHECK_STATUS   ENDP

SUBTTL         CRC_PROTECTION

PAGE

; -------------------------------------------------------------------------
; |                                                                       |
; |                           CRC PROTECTION                              |
; |                                                                       |
; |             INFORMS THE USER THAT A CRC PROTECTION SCHEME             |
; |             MAY BE EMPLOYED (OTHER POSSIBILITY IS DISK IS             |
; |                  CONTAMINATED OR ITS OXIDE IS GONE)                   |
; |                                                                       |
; -------------------------------------------------------------------------

CRC_PROTECTION  PROC   NEAR

                PUSH   AX
                PUSH   BX
                PUSH   CX
                PUSH   DX

; FLUSH KEY BOARD BUFFER

        FLUSH_BUFFER:

                MOV    AH,1
                INT    16H
                JZ     DISPLAY_CRC

                MOV    AH,0
                INT    16H
                JMP    FLUSH_BUFFER

; DISPLAY " CRC PROTECTION SCHEME MAY BE EMPLOYED '

        DISPLAY_CRC:

                MOV    BX,OFFSET CRC_M
                MOV    AL,COL_SIZE
                MOV    AH,CRC_LEN
                SUB    AL,AH
                SHR    AL,1
                MOV    CL,CRC_LEN
                MOV    CH,0F0H
                MOV    AH,0
                CALL   DISP_STRING

; DISPLAY " IF MASTER KEY WILL COPY DISK BYT CODE MUST BE '

                MOV    BX,OFFSET MESS_1_M
                MOV    AL,COL_SIZE
                MOV    AH,MESS_1_LEN
                SUB    AL,AH
                SHR    AL,1
                MOV    CL,MESS_1_LEN
                MOV    CH,07H
                MOV    AH,2
                CALL   DISP_STRING

; DISPLAY " IN ORDER FOR PROGRAM TO EXECUTE '

                MOV    BX,OFFSET MESS_2_M
                MOV    AL,COL_SIZE
                MOV    AH,MESS_2_LEN
                SUB    AL,AH
                SHR    AL,1
                MOV    CL,MESS_2_LEN
                MOV    CH,07H
                MOV    AH,4
                CALL   DISP_STRING

; DISPLAY " ==== OTHER POSSIBILITY ====> SECTOR MAY BE DAMAGED "

                MOV    BX,OFFSET POSS_M
                MOV    AL,COL_SIZE
                MOV    AH,POSS_LEN
                SUB    AL,AH
                SHR    AL,1
                MOV    CL,POSS_LEN
                MOV    CH,07H
                MOV    AH,6
                CALL   DISP_STRING

; DISPLAY " HIT RETURN TO CONTINUE "

                MOV    BX,OFFSET RET_M
                MOV    AL,COL_SIZE
                MOV    AH,RET_L
                SUB    AL,AH
                SHR    AL,1
                MOV    CL,RET_L
                MOV    CH,07H
                MOV    AH,8
                CALL   DISP_STRING

                CALL   RETURN

                MOV    AH,6
                MOV    AL,0
                MOV    CX,0
                MOV    DX,0950H
                MOV    BH,07H
                INT    10H

                POP    DX
                POP    CX
                POP    BX
                POP    AX

                RET

CRC_PROTECTION  ENDP

; -------------------------------------------------------------------------
; |                                                                       |
; |                       DISPLAY MAP SCREEN                              |
; |                                                                       |
; -------------------------------------------------------------------------

DISP_MAP_SCREEN PROC    NEAR

                PUSH    AX
                PUSH    BX
                PUSH    CX
                PUSH    DX

; DISPLAY MAPPING MESSAGE

                MOV     AL,4
                CALL    PROG_DISP

; DISPLAY FORMAT TYPE

                MOV      BX,PARAMETER_ADDRESS
                CALL     DISP_FORMAT_TYPE

; DISPLAY SEARCHING SECTOR MESSAGE

                MOV     AL,SEARCH_SECTOR_NUMBER
                CALL    DISP_SEARCH_SECTOR

; DISPLAY FOUND SECTOR INFORMATION
 
                MOV     AL,FOUND_SECTOR_NUMBER
                MOV     AH,NUMBER_OF_FOUND_SECTORS
                CALL    DISP_FOUND_SECTOR

                POP     DX
                POP     CX
                POP     BX
                POP     AX

                RET

DISP_MAP_SCREEN ENDP

CODE_SEG       ENDS

               END