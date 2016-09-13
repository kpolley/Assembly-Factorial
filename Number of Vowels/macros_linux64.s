; macros_linux64.s
;
;
; I/O macro collection for COSC2425, Spring 2011, Prof. Bill Tucker
;	(64bit Linux edition)
;
;
;***************************************
;   version as at  5 November 2011     *
;***************************************
;
;
; commissioned by Prof. Bill Tucker
; initial draft by Christopher Shaltz
; initial testing by class COSC 2425, Fall 2010
; ported to assemble with NASM, Spring 2011
; 64bit linux port for Fall 2011
;
;
;**************************************************************************
;   **** For Training Purposes Only ****
;
;   This code is intended to be reasonably safe and effective for student use,
;       and is *not* intended to be particularly efficient implementations.
;       
;   This is a work in progress.
;
;**************************************************************************
;
;
;
;**************************************************************************
;
;	MACRO LIBRARY CALLS
;
;
;   PutCh value8	    parameter MUST be an 8 bit value (immediate, register, or direct)
;                           prints a single ascii character to stdout
;
;   PutStr address	    parameter MUST be the address of a null terminated string
;                           prints asciiz string to stdout
;
;   nwln	            no parameter required
;                           prints a single newline character to stdout
;
;   PutInt value16	    parameter MUST be a 16 bit value (immediate, register, or direct)
;                           prints a 16-bit 2's complement integer to stdout
;
;   PutLInt value32	    parameter MUST be a 32 bit value (immediate, register, or direct)
;                           prints a 32-bit 2's complement integer to stdout
;
;   PutQInt value64	    parameter MUST be a 64 bit value (immediate, register, or direct)
;                           prints a 64-bit 2's complement integer to stdout
;
;   PutHex value16	    parameter MUST be a 16 bit value (immediate, register, or direct}
;                           prints a 16-bit integer to stdout as an unsigned hexadecimal (left padded with 0s)
;
;   PutLHex value32	    parameter MUST be a 32 bit value (immediate, register, or direct}
;                           prints a 32-bit integer to stdout as an unsigned hexadecimal (left padded with 0s)
;
;   PutQHex value64	    parameter MUST be a 64 bit value (immediate, register, or direct}
;                           prints a 64-bit integer to stdout as an unsigned hexadecimal (left padded with 0s)
;
;   DumpRegs		    no parameter required
;                           displays the contents of the gp registers, seg regs, rip, and rflags
;
;   GetCh value8        parameter MUST be an 8 bit location (register, or memory)
;                           returns an 8 bit ASCII character in the specified location
;
;   GetStr address size
;						first parameter MUST be a memory location
;                           fills specified location with a NULL terminated ASCII string (default max size 80 chars + 1 NULL)
;
;   GetInt dest16	parameter MUST be a 16 bit location (register, or memory)
;                           returns a 16 bit 2's complement integer in the specified location
;
;   GetLInt dest32	parameter MUST be a 32 bit location (register, or memory)
;                           returns a 32 bit 2's complement integer in the specified location
;
;   GetQInt dest64	parameter MUST be a 64 bit location (register, or memory)
;                           returns a 64 bit 2's complement integer in the specified location
;
;   GetHex dest16	parameter MUST be a 16 bit location (register, or memory)
;                           returns a 16 bit 2's complement integer in the specified location
;
;   GetLHex dest32	parameter MUST be a 32 bit location (register, or memory)
;			    returns a 32 bit 2's complement integer in the specified location
;
;   GetQHex dest32	parameter MUST be a 64 bit location (register, or memory)
;			    returns a 64 bit 2's complement integer in the specified location
;
;**************************************************************************


; extern labels, for calling C standard library functions
extern printf, putchar, getchar, scanf, fgets, stdin


; constant equates
WORDSIZE  			EQU	8		; size of a machine word (in bytes)

MAXBUFFERLENGTH		EQU	161		; size of GetStr macro's procedure's buffer

__SPACE				EQU	32		; ASCII codes
__TAB				EQU	9
__CR				EQU 13
__LF				EQU 10
__NULL				EQU	0
__NEWLINE			EQU	10

; C function parameters
%define FIRST	rdi
%define SECOND	rsi
%define THIRD	rdx
%define FOURTH	rcx


SECTION .data

; strings for formatting inputs and outputs
__PutStrText:
    DB  "%s", 0
__PutIntText:
    DB  "%hd", 0
__PutLIntText:
    DB  "%d", 0
__PutQIntText:
    DB  "%ld", 0
__GetIntText:
    DB  " %hd", 0        	; skips leading whitespace
__GetLIntText:
    DB  " %d", 0         	; skips leading whitespace
__GetQIntText:
    DB  " %ld", 0         	; skips leading whitespace
__GetHexText:
    DB  " %hx", 0        	; skips leading whitespace
__GetLHexText:
    DB  " %x", 0         	; skips leading whitespace
__GetQHexText:
    DB  " %lx", 0         	; skips leading whitespace
__PutHexText:
    DB  "%04x", 0
__PutLHexText:
    DB  "%08x", 0
__PutQHexText:
    DB  "%016lx", 0

; pretty printing for DumpRegs
__DumpRegsText1:
    DB  "rax: %016lx   rbx: %016lx   rcx: %016lx", 13, 10, 0
__DumpRegsText2:
    DB  "rdx: %016lx   rsi: %016lx   rdi: %016lx", 13, 10, 0
__DumpRegsText3:
    DB  "rbp: %016lx   rsp: %016lx   r08: %016lx", 13, 10, 0
__DumpRegsText4:
    DB  "r09: %016lx   r10: %016lx   r11: %016lx", 13, 10, 0
__DumpRegsText5:
    DB  "r12: %016lx   r13: %016lx   r14: %016lx", 13, 10, 0
__DumpRegsText6:
    DB  "r15: %016lx   rip: %016lx   rflags: %016lx", 13, 10, 0
__DumpRegsText7:
    DB  "cs: %04x    ds: %04x    ss: %04x    ", 0
__DumpRegsText8:
    DB  "es: %04x    fs: %04x    gs: %04x", 13, 10, 0

; place for GetXX macros to put results (up to 64bits of data)
__ScalarStorage:
    DQ   0


SECTION .bss
__getStrProcBuffer:
	RESB	MAXBUFFERLENGTH

; subroutine for dumping out the integer registers to console
;   NB:  rip will display the address of the instruction *following* the DumpRegs macro
SECTION .text
__DumpRegs:
    push    rbp
    mov     rbp, rsp

    pushfq
    push    rax
    push    rbx
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    push    r12
    push    r13
    push    r14
    push    r15

    ; rax  rbx  rcx
    mov     rdi, __DumpRegsText1
    mov     rsi, [rbp-16]
    mov     rdx, [rbp-24]
    mov     rcx, [rbp-32]
    mov     eax, 0
    call    printf

    ; rdx  rsi  rdi
    mov     rdi, __DumpRegsText2
    mov     rsi, [rbp-40]
    mov     rdx, [rbp-48]
    mov     rcx, [rbp-56]
    mov     eax, 0
    call    printf

    ; rbp  rsp  r08
    mov     rdi, __DumpRegsText3
    mov     rsi, [rbp]
    mov     rdx, rbp
    add     rdx, WORDSIZE * 2
    mov     rcx, [rbp-64]
    mov     eax, 0
    call    printf

    ; r09  r10  r11
    mov     rdi, __DumpRegsText4
    mov     rsi, [rbp-72]
    mov     rdx, [rbp-80]
    mov     rcx, [rbp-88]
    mov     eax, 0
    call    printf

    ; r12  r13  r14
    mov     rdi, __DumpRegsText5
    mov     rsi, [rbp-96]
    mov     rdx, [rbp-104]
    mov     rcx, [rbp-112]
    mov     eax, 0
    call    printf

    ; r15  rip  rflags
    mov     rdi, __DumpRegsText6
    mov     rsi, [rbp-120]
    mov     rdx, [rbp+8]
    mov     rcx, [rbp-8]
    mov     eax, 0
    call    printf

    ; standard segments
    mov     rdi, __DumpRegsText7
    xor     rax, rax
    mov     eax, cs
    mov     rsi, rax
    mov     eax, ds
    mov     rdx, rax
    mov     eax, ss
    mov     rcx, rax
    mov     eax, 0
    call    printf

    ; extended segments
    mov     rdi, __DumpRegsText8
    xor     rax, rax
    mov     eax, es
    mov     rsi, rax
    mov     eax, fs
    mov     rdx, rax
    mov     eax, gs
    mov     rcx, rax
    mov     eax, 0
    call    printf


    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rax
    popfq

    mov     rsp, rbp
    pop     rbp
    ret
; end of __DumpRegs


; procedure called by GetStr macro
;	first parameter (rdi) is address to store string at
;	second parameter (rsi) is maximum # of characters to read (macro defaults to 81)
;	all other registers are preserved or unused excpet r8-r11
__getStrProc:
	push	rbp
	mov		rbp, rsp
	push	rdx
	push	rax
	push	rcx

	push	rdi				; stash destination address

	cmp		rsi, MAXBUFFERLENGTH
	jle		getStrProc0
	mov		rsi, MAXBUFFERLENGTH

getStrProc0:
;	push	rsi				; stash limit value

	mov		rdi, __getStrProcBuffer
	mov		rdx, [stdin]
	call	fgets

;	pop		rdx				; pop limit (was in rsi)
	pop		rdi				; retrieve destination address
	mov		rsi, __getStrProcBuffer

	; rsi points into static buffer, rdi points into caller's buffer

	jmp		getStrProc2		; skip increment first time into scan loop

getStrProc1:
	inc		rsi
getStrProc2:				; scan past whitespace to find start of 'actual' string
	mov		dl, [rsi]
	cmp		dl, __SPACE
	je		getStrProc1
	cmp		dl, __TAB
	je		getStrProc1
	cmp		dl, __CR
	je		getStrProc1
	cmp		dl, __LF
	je		getStrProc1

getStrProc3:				; copy until ASCII zero
	mov		[rdi], dl
	inc		rdi
	inc		rsi
	mov		dl, [rsi]
	cmp		dl, __NULL
	jne		getStrProc3

	dec		rdi				; if the last char copied was a newline, kill it
	mov		dl, [rdi]
	cmp		dl, __NEWLINE
	je		getStrProc4
	inc		rdi

getStrProc4:				; write the terminating ASCII NULL
	mov		dl, __NULL
	mov		[rdi], dl

	pop		rcx
	pop		rax
	pop		rdx
    mov     rsp, rbp
    pop     rbp
	ret
; end of __getStrProc


; support macros

%macro PUSH5 0		; push 5 of the volatile regs (A, C, D, SI, DI)
    push    rax
    push    rdi
    push    rsi
    push    rdx
    push    rcx
%endmacro


%macro POP5 0		; pop the same 5 volatile regs (A, C, D, SI, DI)
    pop     rcx
    pop     rdx
    pop     rsi
    pop     rdi
    pop     rax
%endmacro


; output macros

%macro PutCh 1         	; parameter MUST be an 8 bit value (immediate, register, or direct)
    pushfq
    PUSH5
    mov     al, %1
    and     rax, 0x00000000000000ff
    mov     rdi, rax
    call    putchar
    POP5
    popfq
%endmacro


%macro PutStr 1       	; parameter MUST be the address of a null terminated string
    pushfq
    PUSH5
    mov     rsi, %1
    mov     rdi, __PutStrText
    mov     rax, 0
    call    printf
    POP5
    popfq
%endmacro


%macro nwln	0			; no parameter required
    pushfq
    PUSH5
    mov     rdi, 0x0d
    call    putchar
    mov     rdi, 0x0a
    call    putchar
    POP5
    popfq
%endmacro


%macro PutInt 1       	; parameter MUST be a 16 bit value (immediate, register, or direct)
    pushfq
    PUSH5
    mov     ax, %1
    movsx   rsi, ax
    mov     rdi, __PutIntText
    mov     rax, 0
    call    printf
    POP5
    popfq
%endmacro


%macro PutLInt 1      	; parameter MUST be a 32 bit value (immediate, register, or direct)
    pushfq
    PUSH5
    mov     eax, %1
    movsx   rsi, eax
    mov     rdi, __PutLIntText
    mov     rax, 0
    call    printf
    POP5
    popfq
%endmacro


%macro PutQInt 1      	; parameter MUST be a 64 bit value (immediate, register, or direct)
    pushfq
    PUSH5
    mov     rsi, %1
    mov     rdi, __PutQIntText
    mov     rax, 0
    call    printf
    POP5
    popfq
%endmacro


%macro PutHex 1        	; parameter MUST be a 16 bit value (immediate, register, or direct}
    pushfq
    PUSH5
    mov     ax, %1
    movzx   rsi, ax
    mov     rdi, __PutHexText
    mov     rax, 0
    call    printf
    POP5
    popfq
%endmacro


%macro PutLHex 1       	; parameter MUST be a 32 bit value (immediate, register, or direct}
    pushfq
    PUSH5
    mov     eax, %1
    mov     rsi, rax
    mov     rdi, __PutLHexText
    mov     rax, 0
    call    printf
    POP5
    popfq
%endmacro


%macro PutQHex 1       	; parameter MUST be a 64 bit value (immediate, register, or direct}
    pushfq
    PUSH5
    mov     rsi, %1
    mov     rdi, __PutQHexText
    mov     rax, 0
    call    printf
    POP5
    popfq
%endmacro


; input macros

%macro GetCh 1
    pushfq
    PUSH5
    call    getchar
    mov     BYTE [__ScalarStorage], al
    POP5
    mov     %1, BYTE [__ScalarStorage]
    popfq
%endmacro


%macro GetStr 1-2	81
    pushfq
	push	rdi
    push	rsi

    mov     rdi, %1
	mov		rsi, %2
    call    __getStrProc

    pop		rsi
	pop		rdi
    popfq
%endmacro


%macro GetInt 1
    pushfq
    PUSH5
    mov     rdi, __GetIntText
    mov     rsi, __ScalarStorage
    mov     rax, 0
    call    scanf
    POP5

    %ifidni    %1, ax
    mov     ax, WORD [__ScalarStorage]
    %else
    push    rax
    mov     ax, WORD [__ScalarStorage]
    mov     %1, ax
    pop     rax
    %endif

    popfq
%endmacro


%macro GetLInt 1
    pushfq
    PUSH5
    mov     rdi, __GetLIntText
    mov     rsi, __ScalarStorage
    mov     rax, 0
    call    scanf
    POP5

    %ifidni %1, eax
    mov     eax, DWORD [__ScalarStorage]
    %else
    push    rax
    mov     eax, DWORD [__ScalarStorage]
    mov     %1, eax
    pop     rax
    %endif

    popfq
%endmacro


%macro GetQInt 1
    pushfq
    PUSH5
    mov     rdi, __GetQIntText
    mov     rsi, __ScalarStorage
    mov     rax, 0
    call    scanf
    POP5

    %ifidni %1, rax
    mov     rax, QWORD [__ScalarStorage]
    %else
    push    rax
    mov     rax, QWORD [__ScalarStorage]
    mov     %1, rax
    pop     rax
    %endif

    popfq
%endmacro


%macro GetHex 1
    pushfq
    PUSH5
    mov     rdi, __GetHexText
    mov     rsi, __ScalarStorage
    mov     rax, 0
    call    scanf
    POP5

    %ifidni %1, ax
    mov     ax, WORD [__ScalarStorage]
    %else
    push    rax
    mov     ax, WORD [__ScalarStorage]
    mov     %1, ax
    pop     rax
    %endif

    popfq
%endmacro


%macro GetLHex 1
    pushfq
    PUSH5
    mov     rdi, __GetLHexText
    mov     rsi, __ScalarStorage
    mov     rax, 0
    call    scanf
    POP5

    %ifidni %1, eax
    mov     eax, DWORD [__ScalarStorage]
    %else
    push    rax
    mov     eax, DWORD [__ScalarStorage]
    mov     %1, eax
    pop     rax
    %endif

    popfq
%endmacro


%macro GetQHex 1
    pushfq
    PUSH5
    mov     rdi, __GetQHexText
    mov     rsi, __ScalarStorage
    mov     rax, 0
    call    scanf
    POP5

    %ifidni %1, rax
    mov     rax, QWORD [__ScalarStorage]
    %else
    push    rax
    mov     rax, QWORD [__ScalarStorage]
    mov     %1, rax
    pop     rax
    %endif

    popfq
%endmacro


; debugging macros

%macro DumpRegs 0           ; no parameter required
    call    __DumpRegs
%endmacro


; segment macros (for Dandamudi compatability)
%macro .CODE 0
    SECTION .text
%endmacro

%macro .DATA 0
    SECTION .data
%endmacro

%macro .UDATA 0
    SECTION .bss
%endmacro


; boiler-plate macros (for Dandamudi compatability)
%macro .STARTUP	0
global main
main:
    push    rbp
    mov     rbp, rsp
%endmacro

%macro .EXIT 0
    xor     rax, rax
    mov     rsp, rbp
    pop     rbp
    ret
%endmacro


; end of macros.s
