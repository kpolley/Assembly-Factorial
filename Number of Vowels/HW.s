; Objective: To print the number of times
; each vowel appears in a string
; Input: Requests a string from keyboard.
; Output: Count for each vowel present

%include "macros_linux64.s"

BUFF_LEN 	EQU	81

.DATA
char_prompt	db "Please input a string: ",0
msg_header	db " Vowel	Count",0
msg_A		db "a or A	  ",0
msg_E		db "e or E	  ",0
msg_I		db "i or I	  ",0
msg_O		db "o or O	  ",0
msg_U		db "u or U	  ",0
query_msg	db "Do you want to quit (Y/N): ",0

.UDATA
string		resb BUFF_LEN

.CODE
        .STARTUP
read_char:
		sub 	EAX, EAX
		sub 	EBX, EBX
		sub 	ECX, ECX
		sub 	EDX, EDX
		
        PutStr	char_prompt		; request a char. input
        GetStr	string,BUFF_LEN	; read input character
		PutStr	msg_header
		nwln
		mov		ESI, string		; move string into source for string loading
get_char:
		lodsb
		cmp 	AL,	0			; checks for end of string
		je 		null_found		; if end of string, processing is done
		cmp		AL, 65			; checks if character is A
		je		vowel_A			; if A, count A
		jl		get_char		; if less, char is not a vowel, get next letter
		cmp		AL, 117			; checks if character is u
		je		vowel_u			; if u, count u
		jg		get_char		; if more, char is not a vowel, get next letter
		cmp		AL, 85			; checks if character is U
		je		vowel_U			; if U, count U
		jl		vowel_E			; if less, upper case, jump to E as A is already checked 
lower_case:						; if all above cmps fail, character is lower case
vowel_a:
		cmp		AL,	97			; check a
		jne		vowel_e			; skip if not a
		inc		AH				; counts a otherwise
		jmp		get_char		; read next character
vowel_e:
		cmp		AL,	101			; check e
		jne		vowel_i			; skip if not e
		inc		BL				; counts e otherwise
		jmp		get_char		; read next character
vowel_i:
		cmp		AL,	105			; check i
		jne		vowel_o			; skip if not i
		inc		BH				; counts i otherwise
		jmp		get_char		; read next character
vowel_o:
		cmp		AL,	111			; check o
		jne		get_char		; if not, next char, u already checked
		inc		CL				; counts o otherwise
		jmp		get_char		; read next character
vowel_u:
		inc		CH				; counts u otherwise
		jmp		get_char		; read next character
upper_case:
vowel_A:
		inc		AH				; counts A
		jmp		get_char		; otherwise read next character

vowel_E:
		cmp		AL,	64			; check E
		jne		vowel_I			; skip if not E
		inc		BL				; counts E otherwise
		jmp		get_char		; read next character
vowel_I:
		cmp		AL,	64			; check I
		jne		vowel_O			; skip if not I
		inc		BH				; counts I otherwise
		jmp		get_char		; read next character

vowel_O:
		cmp		AL,	64			; check O
		jne		get_char		; skip if not A
		inc		CL				; if not, next char, U already checked
		jmp		get_char		; read next character
vowel_U:
		inc		CH				; counts U otherwise
		jmp		get_char		; read next character
null_found:
		mov		DL, AH			; move number of A's into D for printing
		PutStr	msg_A
		PutInt	DX				; print number of vowels
		nwln
		mov		DL, BL			; move number of E's into D for printing
		PutStr	msg_E
		PutInt	DX				; print number of vowels
		nwln
		mov		DL, BH			; move number of I's into D for printing
		PutStr	msg_I
		PutInt	DX				; print number of vowels
		nwln
		mov		DL, CL			; move number of O's into D for printing
		PutStr	msg_O
		PutInt	DX				; print number of vowels
		nwln
		mov		DL, CH			; move number of U's into D for printing
		PutStr	msg_U
		PutInt	DX				; print number of vowels
		nwln
        PutStr 	query_msg		; query user whether to terminate
        GetCh	BL				; read response
        GetCh	AL				; read return character received with input
        nwln
		
        cmp 	BL,'Y'			; if response is ’Y’
        je		done			; terminate program
		cmp 	BL,'y'			; if response is ’y’
        je		done			; terminate program
		jmp		read_char		; otherwise back to top
done:							
        .EXIT
