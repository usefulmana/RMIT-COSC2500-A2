*-----------------------------------------------------------
* Title      : COSC2500 Assignment I
* Written by : Nguyen Le Bao Anh
* ID         : s3616128
* Date       : 26/12/2018
* Description: This program will convert a base(2,8,10,16) number to other bases.
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Input Menu
MAINLOOP    LEA     INMENU,A1 ; displays main menu 
            MOVE.B  #18,D0
            TRAP    #15
            
            CMP.L   #1,D1      
            BEQ     BINARY    ; Enter binary conversion mode if 1 is entered
            CMP.L   #2,D1
            BEQ     OCTAL   ; Enter octal conversion mode if 2 is entered
            CMP.L   #3,D1
            BEQ     DECIMAL  ; Enter decimal conversion mode if 3 is entered
            CMP.L   #4,D1
            BEQ     HEXA   ; Enter hexadecimal conversion mode if 4 is entered
            BRA     DONE      ; Exit program if anything else is entered
            
* Converting decimal input to all bases
DECIMAL: JSR     DECIN         ; Display an indication to enter decimal digits in window. 
         JSR     DECGETCHR     ; Start a loop to wait for and read decimal digits. 
         JSR     DECDETVAL     ; Determine the value of all the digits interpreted as a single value. 
         JSR     DECTODEC      ; Convert to decimal characters. 
         JMP     DECDONE
   
DECIN:  LEA     DECIMALMENU, A1 ; Decimal input menu
        MOVE.B  #14, D0    
        TRAP    #15        
        RTS
   
DECGETCHR:  LEA     INPUT, A1  ; Store the address to write the results to in A1. 
            MOVE.B  #0, D2     ; Count the number of digits processed. 
DECNXTCHR:  MOVE    #5, D0     ; Select the subroutine to read a character from the keyboard.
            TRAP    #15        
            CMP.B   #13, D1    ; The character is placed into the LSB of D1.
            BEQ     DECGCDONE     ; End if the <Return> key was pressed. 
            JSR     DECASCII     ; Jump to the subroutine to check and convert decimal digits. 
            JMP     DECNXTCHR     ; Read the next character. 
DECGCDONE: RTS
   
DECASCII:   CMP.B   #48, D1    ; Check if a digit is in the range of 0 to 9. 48 and 57 are 0 & 9 decimal values respectively in the ASCII table.
            BLT     DECINVAL
            CMP.B   #57, D1
            BGT     DECINVAL
            SUB.B   #48, D1     ; Subtract 48 which is 0 from the digit to get the decimal values of the digit.
            JMP     DECSTORE     
         
DECSTORE:    MOVE.B  D1,(A1)+   ; Write the converted value to memory starting at $2000. 
             ADD     #1, D2     ; Increment the count of decimal digits read. 
             RTS                 
   
DECDETVAL:  MOVE.L  #0, D3     ; Use D3 to hold the total value. 
            MOVE.L  #10, D4    ; Use D4 to multiply by 10. 
            MOVE.B  -(A1),D3   ; Get the least significant byte.
 
DECNXTDIG:  SUB.B   #1, D2     ; Decrement the counter by one. 
            CMP.B   #0, D2     ; See if there are any more digits to process. 
            BEQ     DECDVDONE
            MOVE.B  -(A1),D5   ; Get the next decimal digit. 
            MULU    D4, D5     ; Multiply it by the power of 10 corresponding to the digit position. 
            ADD.L   D5, D3     ; Total the current digit with the sum so far. 
            MULU    #10, D4    ; Increase the decimal digit multiplying power.
            BRA     DECNXTDIG     ; See if there are any more digits to process. 
DECDVDONE: RTS 

DECTODEC:   LEA     DECHRS, A1 ; 
            MOVE.L  #0, D5     ; Our counter for decimal digits. 
            MOVE    D3, D4     ; Make a copy of the total value.
DECTOALL    MOVE D4, D1        ; Converting the decimal value to other bases.
            MOVE #2, D2
            MOVE #15, D0
            TRAP #15
            
            MOVE #8, D2
            TRAP #15
            MOVE #10, D2
            TRAP #15
            MOVE #16, D2
            TRAP #15
         
DECNXTDEC:  MOVE    D4, D1     ;   
            CMP.L   #0, D4     ; Stop when there are no more digits left to process. 
            BLE     DECTDDONE     
            DIVU    #10, D4
            MULU    #10, D4
            SUB.W   D4, D1     ; 
            ADD.W   #48, D1    ; Convert the value to the corresponding character. 
            MOVE.B  D1,(A1)+   ; Store the decimal character. 
            DIVU    #10, D4    ; Find the next decimal digit. 
            ADD     #1, D5     ; Increment the decimal digit counter. 
            BRA     DECNXTDEC
DECTDDONE: RTS 

            
DECINVAL	LEA 	ERR,A1 ; Display error notice.
	        MOVE.B	#13,D0
	        TRAP	#15
	        BRA	    DECIMAL ; Return to input menu.
     
DECDONE     LEA     CONMES,A1 ; Display continue message.
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.B  #5,D0
            TRAP    #15
            CMP.B   #$79,D1  ; Compare to value of y in ASCII table.
            BEQ     DECIMAL ; Continue if equal.
            CMP.B   #$59,D1  ; Compare to value of Y in ASCII table.
            BEQ     DECIMAL ; Continue if equal.
            BRA     MAINLOOP ; Return to main menu if any other input is entered.
            
* Stop simulator with message
DONE        LEA     EXITMES,A1 ; Display goodbye message
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.B  #9,D0 ; Quit program
            TRAP    #15         
        
* Octal conversion
OCTAL:  JSR     OCTIN     ; Display an indication to enter octal digits in window. 
        JSR     GETCHR     ; Start a loop to wait for and read octal digits. 
        JSR     DETVAL     ; Determine the value of all the digits interpreted as a single value. 
        JSR     TODEC      ; Convert to decimal characters. 
        JMP     OCTDONE
   
OCTIN:  LEA     OCTALMENU, A1 ; Displays octal input menu.
        MOVE.B  #14, D0     
        TRAP    #15         
        RTS
   
GETCHR: LEA     INPUT, A1  ; Store the address to write the results to in A1. 
        MOVE.B  #0, D2     ; Count the number of digits processed. 
NXTCHR: MOVE    #5, D0     ; Select the subroutine to read a character from the keyboard.
        TRAP    #15        ; Start the character input subroutine. 
        CMP.B   #13, D1    ; The character is placed into the LSB of D1.
        BEQ     GCDONE     ; End if the <Return> key was pressed. 
        JSR     HX2BIN     ; Jump to the subroutine to check and convert octal digits. 
        JMP     NXTCHR     ; Read the next character. 
GCDONE: RTS
   
HX2BIN: CMP.B   #48, D1    ; Check if a digit is in the range of 0 to 7. 48 and 55 are 0 & 7 decimal values respectively in the ASCII table. 
        BLT     OCTINVAL
        CMP.B   #55, D1
        BGT     OCTINVAL
        SUB.B   #48, D1    ; Subtract 48 which is 0 from the digit to get the decimal values of the digit.
        JMP     STORE      ; 

STORE:  MOVE.B  D1,(A1)+   ; Write the converted value to memory starting at $2000. 
        ADD     #1, D2     ; Increment the count of octal digits read. 
        RTS                   
DETVAL: MOVE.L  #0, D3     ; Use D3 to hold the total value. 
        MOVE.L  #8, D4    ; Use D4 to multiply by 8. 
        MOVE.B  -(A1),D3   ; Get the least significant byte. 
NXTDIG: SUB.B   #1, D2     ; Decrement the counter by one. 
        CMP.B   #0, D2     ; See if there are any more digits to process. 
        BEQ     DVDONE
        MOVE.B  -(A1),D5   ; Get the next octal digit. 
        MULU    D4, D5     ; Multiply it by the power of 8 corresponding to the digit position. 
        ADD.L   D5, D3     ; Total the current digit with the sum so far. 
        MULU    #8, D4    ; Increase the octal digit multiplying power.
        BRA     NXTDIG     ; See if there are any more digits to process. 
DVDONE: RTS 

TODEC:  LEA     DECHRS, A1 ; 
        MOVE.L  #0, D5     ; Our counter for decimal digits. 
        MOVE    D3, D4     ; Make a copy of the total value.
OCTTOALL    MOVE D4, D1    ; Converting the decimal value to other bases.
            MOVE #2, D2
            MOVE #15, D0
            TRAP #15
            MOVE #8, D2
            TRAP #15
            MOVE #10, D2
            TRAP #15
            MOVE #16, D2
            TRAP #15
         
NXTDEC: MOVE    D4, D1     ;   
        CMP.L   #0, D4     ; Stop when there are no more digits left to process. 
        BLE     TDDONE     ;
        DIVU    #10, D4
        MULU    #10, D4
        SUB.W   D4, D1     ; 
        ADD.W   #48, D1    ; Convert the value to the corresponding character. 
        MOVE.B  D1,(A1)+   ; Store the decimal character. 
        DIVU    #10, D4    ; Find the next decimal digit. 
        ADD     #1, D5     ; Increment the decimal digit counter. 
        BRA     NXTDEC
TDDONE: RTS 

            
OCTINVAL	LEA 	ERR,A1 ; Display error message.
	        MOVE.B	#13,D0
	        TRAP	#15
	        BRA	    OCTAL ; Return to input menu.
     
OCTDONE     LEA     CONMES,A1 ;Display continue message.
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.B  #5,D0
            TRAP    #15
            CMP.B   #$79,D1  ;Compare to value of y in ASCII table.
            BEQ     OCTAL ; Continue if equal.
            CMP.B   #$59,D1  ; Compare to value of Y in ASCII table.
            BEQ     OCTAL ; Continue if equal.
            BRA     MAINLOOP ; Return to main menu if anything else is entered. 
* Hexa range check
HEXA:    JSR     HEXIN     ; Display an indication to enter hex digits in window. 
         JSR     HEXGETCHR     ; Start a loop to wait for and read hex digits. 
         JSR     HEXDETVAL     ; Determine the value of all the digits interpreted as a single value. 
         JSR     HEXTODEC      ; Convert to decimal characters. 
         JMP     HEXDONE
   
HEXIN:  LEA     HEXMENU, A1 ; Load the user prompt address into A1.
        MOVE.B  #14, D0    ; Select subroutine to display a string to user. 
        TRAP    #15        ; Start the subroutine to display the prompt. 
        RTS
   
HEXGETCHR:  LEA     INPUT, A1  ; Store the address to write the results to in A1. 
            MOVE.B  #0, D2     ; Count the number of digits processed. 
HEXNXTCHR:  MOVE    #5, D0     ; Select the subroutine to read a character from the keyboard.
            TRAP    #15        ; Start the character input subroutine. 
            CMP.B   #13, D1    ; The character is placed into the LSB of D1.
            BEQ     HEXGCDONE     ; End if the <Return> key was pressed. 
            JSR     HEXASCII     ; Jump to the subroutine to check and convert hex digits. 
            JMP     HEXNXTCHR     ; Read the next character. 
HEXGCDONE: RTS
   
HEXASCII:   CMP.B   #48, D1    ; If less than 48 decimal (0) in ASCII table, disqualify. 
            BLT     HEXINVAL                 
            CMP.B   #57, D1    ; See if the digit is in the range 0-9 or A-F.
            BLE.B   LTE9       ; If the difference is less than or equal to 0, it's 0-9, go to LTE16 branch
            CMP.B   #65, D1    ; If less than 65 decimal (A) in ASCII table, disqualify.
            BLT     HEXINVAL       
            CMP.B   #71, D1    ; See if the digit is in the range 0-9 or A-F.
            BGE     HEXINVAL       ; If the difference is greater than, disqualify.
            SUB.B   #55, D1    ; 'A' is decimal 65, subtract 55 for decimal values A-F.
            JMP     HEXSTORE      ; Store the result. 
LTE9:      SUB.B   #48, D1    ; '0' is decimal 48, subtract 48 for decimal values 0-9.
            JMP     HEXSTORE    ; Store the result.
HEXSTORE:   MOVE.B  D1,(A1)+   ; Write the converted value to memory starting at $2000. 
            ADD     #1, D2     ; Increment the count of hex digits read. 
            RTS                ; We've completed this character, see if there's more to do. 
   
HEXDETVAL:  MOVE.L  #0, D3     ; Use D3 to hold the total value. 
            MOVE.L  #16, D4    ; Use D4 to multiply by 16. 
            MOVE.B  -(A1),D3   ; Get the least significant byte. 
HEXNXTDIG:  SUB.B   #1, D2     ; Decrement the counter by one. 
            CMP.B   #0, D2     ; See if there are any more digits to process. 
            BEQ     HEXDVDONE
            MOVE.B  -(A1),D5   ; Get the next hex digit. 
            MULU    D4, D5     ; Multiply it by the power of 16 corresponding to the digit position. 
            ADD.L   D5, D3     ; Total the current digit with the sum so far. 
            MULU    #16, D4    ; Increase the hex digit multiplying power.
            BRA     HEXNXTDIG     ; See if there are any more digits to process. 
HEXDVDONE: RTS 

HEXTODEC:   LEA     DECHRS, A1 ; 
            MOVE.L  #0, D5     ; Our counter for decimal digits. 
            MOVE    D3, D4     ; Make a copy of the total value.
HEXTOALL    MOVE D4, D1        ; Convert decimal values to other bases.
            MOVE #2, D2
            MOVE #15, D0
            TRAP #15
            
            MOVE #8, D2
            TRAP #15
            MOVE #10, D2
            TRAP #15
            MOVE #16, D2
            TRAP #15
         
HEXNXTDEC: MOVE    D4, D1     ;   
        CMP.L   #0, D4     ; Stop when there are no more digits left to process. 
        BLE     HEXTDDONE     ;
        DIVU    #10, D4
        MULU    #10, D4
        SUB.W   D4, D1     ; 
        ADD.W   #48, D1    ; Convert the value to the corresponding character. 
        MOVE.B  D1,(A1)+   ; Store the decimal character. 
        DIVU    #10, D4    ; Find the next decimal digit. 
        ADD     #1, D5     ; Increment the decimal digit counter. 
        BRA     HEXNXTDEC
HEXTDDONE: RTS 

            
HEXINVAL	LEA 	ERR,A1 # display error notice
	        MOVE.B	#13,D0
	        TRAP	#15
	        BRA	    HEXA
     
HEXDONE     LEA     CONMES,A1
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.B  #5,D0
            TRAP    #15
            CMP.B   #$79,D1  # compare to value of y in ASCII table
            BEQ     HEXA # continue if equal
            CMP.B   #$59,D1  # compare to value of Y in ASCII table
            BEQ     HEXA # return to main menu if equal
            BRA     MAINLOOP # return to main menu if equal        
* Binary range check //TODO not done. Fix DONE		
BINARY:  JSR     BIIN     ; Display an indication to enter binary digits in window. 
         JSR     BIGETCHR     ; Start a loop to wait for and read binary digits. 
         JSR     BIDETVAL     ; Determine the value of all the digits interpreted as a single value. 
         JSR     BITODEC      ; Convert to decimal characters. 
         JMP     BIDONE
   
BIIN:   LEA     BINARYMENU, A1 ; Load the user prompt address into A1.
        MOVE.B  #14, D0    ; Select subroutine to display a string to user. 
        TRAP    #15        ; Start the subroutine to display the prompt. 
        RTS
   
BIGETCHR: LEA     INPUT, A1  ; Store the address to write the results to in A1. 
          MOVE.B  #0, D2     ; Count the number of digits processed. 
BINXTCHR: MOVE    #5, D0     ; Select the subroutine to read a character from the keyboard.
          TRAP    #15        ; Start the character input subroutine. 
          CMP.B   #13, D1    ; The character is placed into the LSB of D1.
          BEQ     BIGCDONE     ; End if the <Return> key was pressed. 
          JSR     BINASCII     ; Jump to the subroutine to check and convert hex digits. 
          JMP     BINXTCHR     ; Read the next character. 
BIGCDONE: RTS
   
BINASCII:   CMP.B   #48, D1    ; Check if a digit is in the range of 0 to 1. 48 and 49 are 0 & 1 decimal values respectively in the ASCII table. 
            BLT     BIINVAL
            CMP.B   #49, D1
            BGT     BIINVAL
            SUB.B   #48, D1    ; Substract 48 to get the decimal value.           
            JMP     BISTORE      

BISTORE:    MOVE.B  D1,(A1)+   ; Write the converted value to memory starting at $2000. 
            ADD     #1, D2     ; Increment the count of binary digits read. 
            RTS                ; We've completed this character, see if there's more to do. 
   
BIDETVAL:   MOVE.L  #0, D3     ; Use D3 to hold the total value. 
            MOVE.L  #2, D4    ; Use D4 to multiply by 2. 
            MOVE.B  -(A1),D3   ; Get the least significant byte. 
BINXTDIG:   SUB.B   #1, D2     ; Decrement the counter by one. 
            CMP.B   #0, D2     ; See if there are any more digits to process. 
            BEQ     BIDVDONE
            MOVE.B  -(A1),D5   ; Get the next binary digit. 
            MULU    D4, D5     ; Multiply it by the power of 2 corresponding to the digit position. 
            ADD.L   D5, D3     ; Total the current digit with the sum so far. 
            MULU    #2, D4    ; Increase the binary digit multiplying power.
            BRA     BINXTDIG     ; See if there are any more digits to process. 
BIDVDONE: RTS 

BITODEC:    LEA     DECHRS, A1 ; 
            MOVE.L  #0, D5     ; Our counter for decimal digits. 
            MOVE    D3, D4     ; Make a copy of the total value.

BITOALL     MOVE D4, D1         ; Convert the decimal value to all bases
            MOVE #2, D2
            MOVE #15, D0
            TRAP #15
            
            MOVE #8, D2
            TRAP #15
            MOVE #10, D2
            TRAP #15
            MOVE #16, D2
            TRAP #15
         
BINXTDEC:   MOVE    D4, D1     ;   
            CMP.L   #0, D4     ; Stop when there are no more digits left to process. 
            BLE     BITDDONE     ;
            DIVU    #10, D4
            MULU    #10, D4
            SUB.W   D4, D1     ; 
            ADD.W   #48, D1    ; Convert the value to the corresponding character. 
            MOVE.B  D1,(A1)+   ; Store the decimal character. 
            DIVU    #10, D4    ; Find the next decimal digit. 
            ADD     #1, D5     ; Increment the decimal digit counter. 
            BRA     BINXTDEC
BITDDONE: RTS 

            
BIINVAL	    LEA 	ERR,A1 ; Display error notice.
	        MOVE.B	#13,D0
	        TRAP	#15
	        BRA	    BINARY   ; Return to input menu.
     
BIDONE     LEA     CONMES,A1
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.B  #5,D0
            TRAP    #15
            CMP.B   #$79,D1  ; Compare to value of y in ASCII table.
            BEQ     BINARY ; Continue if equal.
            CMP.B   #$59,D1  ; compare to value of Y in ASCII table.
            BEQ     BINARY ; Continue if equal.
            BRA     MAINLOOP ; Return to main menu if equal.

* Put variables and constants here
CR 	EQU	$0D
LF	EQU	$0A

INMENU      DC.B '',CR,LF                                         ; Main menu options
            DC.B 'Choose a number system for your input:',CR,LF
            DC.B '1. Binary',CR,LF
            DC.B '2. Octal',CR,LF
            DC.B '3. Decimal',CR,LF
            DC.B '4. Hexadecimal',CR,LF
            DC.B 'Enter anything else to exit the program',CR,LF
            DC.B 'Your choice: ',0

DECIMALMENU  DC.B '',CR,LF
             DC.B 'Enter a decimal number: ',0
            
OCTALMENU   DC.B '',CR,LF
            DC.B 'Enter an octal number: ',0
 
BINARYMENU  DC.B '',CR,LF
            DC.B 'Enter a binary number: ',0 
            
HEXMENU     DC.B '',CR,LF
            DC.B 'Enter a hexadecimal number (i.e 123A, case-sensitive):',0   
        
INPUT:  DS.B    8         ; Converted values are written here. 
DECHRS: DS.B    8         ; Decimal character representation of number. 

ERR:    DC.B    '',CR,LF  ; Error message
        DC.B    'Out of range! Please try again',0

CONMES      DC.B '',CR,LF ; Continue prompt
            DC.B 'Continue (y/n)?',0

EXITMES     DC.B ' ',CR,LF ; Exit Message
            DC.B 'Goodbye! Have a great day!',CR,LF
            DC.B 'Author: Nguyen Le Bao Anh',CR,LF
            DC.B 'ID#   : s3616128',0


    END    START        ; last line of source










*~Font name~Courier New~
*~Font size~18~
*~Tab type~1~
*~Tab size~4~
