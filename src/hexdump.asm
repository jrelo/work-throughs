; Dump file as 16-bytes of hex per line
; hexdump < <input file>

SECTION .bss
	BufLen equ 16
	Buf resb BufLen

SECTION .data
	HexStr db "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00", 0x0A
	HexLen equ $-HexStr
	Digits db "0123456789ABCDEF"

SECTION .text
global _start

_start:
Read:	
	mov eax, 3		; `sys_read` syscall
	mov ebx, 0		; Use stdin
	mov ecx, Buf		; Read into buffer
	mov edx, BufLen		; Read BufferSize bytes
	int 0x80		; Make syscall

	mov esi, eax		; Number of characters read in esi, for later

	cmp eax, 0		; Have we reached the end of the file?
	je Exit			; If so, exit

	mov ebp, Buf		; Address of Buffer
	mov edi, HexStr		; Address of line string

	xor ecx, ecx		; Clear ecx

Scan:
	xor eax, eax		; Clear eax

	; Put current character in eax and ebx
	mov al, byte [ebp+ecx]
	mov ebx, eax

	; Isolate high nybble
	shr bl, 4			; Shift high nybble into low bits
	mov bl, byte [Digits+ebx]	; Look up the current char in Digits

	; Isolate low nybble
	and al, 0x0F			; Mask out low nybble
	mov al, byte [Digits+eax]	; Look up the current char in Digits

	; Offset into HexStr for high nybble should be ecx * 3:
	; 00 00 00
	; ^ byte 0, offset 0
	;    ^ byte 1, offset 3
	;       ^ byte 2, offset 6
	mov edx, ecx		; Copy current character count into edx
	shl edx, 1		; Multiply by 2
	add edx, ecx		; Complete multiplication by 3

	; Insert high and low nybbles at offset and offset+1 respectively
	mov byte [HexStr+edx], bl	; Write high nybble char
	mov byte [HexStr+edx+1], al	; Write low nybble char

	; Go to next character and see if we're done
	inc ecx			; Increment line string pointer
	cmp ecx, esi		; Compare with number of chars
	jna Scan		; Loop back if ecx is <= number of chars

	; Write the line to stdout
	mov eax, 4		; `sys_read` syscall
	mov ebx, 1		; Use stdout
	mov ecx, HexStr		; Write byte from buffer
	mov edx, HexLen		; Write number of characters that were read
	int 0x80		; Make syscall
	jmp Read		; Get another buffer

Exit:
	mov eax, 1		; `exit` syscall
	mov ebx, 0		; Exit code 0
	int 0x80		; Exit

