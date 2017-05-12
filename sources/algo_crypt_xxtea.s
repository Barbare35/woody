section .data

section .bss

section .text
	global crypt_xxtea:function

;; void crypt_xxtea(uint32_t *block, uint32_t len, uint32_t *key)
;;				--> rdi				--> rsi			--> rdx

crypt_xxtea:
	push rbp
	mov rbp, rsp
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15

	.init:
		xor r8, r8						;; == DELTA
		xor r10, r10
		xor rbx, rbx					;; TO DEL

		;; START QUANTUM CALCULATE
		push rdx
		xor rdx, rdx
		mov rax, 0x32
		mov r10d, esi
		div r10							;; RDX:RAX (rax = div, rdx = Mod)
		add rax, 6
		mov r9, rax						;; Sauvegarde du quantum
		pop rdx
		;; END QUANTUM CALCULATE

	.prepare_buffer:
		mov r15, rsi
		dec r15
		mov r10d, dword [rdi + r15 * 4]		;; z_buffer
		push r10
		xor r10, r10
		mov r10d, dword [rdi]			;; y_buffer
		push r10

	.loop:
		cmp r9, 0
		je .end_loop
		dec r9
		add r8d, 0x9e3779b9				;; sum += DELTA
		mov r10d, r8d
		shr r10d, 0x2
		and r10d, 0x3
		xor r11, r11

	.snd_loop:
		mov r15, rsi
		dec r15
		cmp r11, r15				;; while r11 < rsi
		je .end_snd_loop
		;; mov y_buffer
		mov r15, r11
		inc r15
		mov r12d, dword [rdi + r15 * 0x4] ;; on prepare y_buffer
		mov dword [rsp], r12d

		;; algo
		call algo

		;; Assign new character
		mov rcx, r11
		call assign

		;; move z_buffer
		mov r12d, dword [rdi + r11 * 0x4]
		mov dword [rsp + 8], r12d
		inc r11
		jmp .snd_loop

	.end_snd_loop:
		;; reset y_block
			mov r12d, dword [rdi]
			mov dword [rsp], r12d ;; y_block = block[0]
		;; algo
			call algo
		;; Assign new character
			mov rcx, rsi
			dec rcx
			call assign

		;; reset z_block
			mov r12, rsi
			dec r12
			mov r12d, dword [rdi + r12 * 0x4]
			mov dword [rsp + 8], r12d
	jmp .loop

.end_loop:
	add rsp, 16

.end:
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	mov rsp, rbp
	pop rbp
	ret

algo:
	push rbp
	mov rbp, rsp
	xor rax, rax
	xor r12, r12
	;; Start bitshift algo
		;; z_buffer = rsp + 24
		;; y_buffer = rsp + 16
		mov r12d, dword [rsp + 24]
		shr r12d, 0x5
		mov r13d, dword [rsp + 16]
		shl r13d, 2
		xor r12d, r13d
		add eax, r12d		;; (z >> 5 ^ y << 2)

		mov r12d, dword [rsp + 16]
		shr r12d, 0x3
		mov r13d, dword [rsp + 24]
		shl r13d, 0x4
		xor r12d, r13d
		add eax, r12d		;; (y >> 3 ^ z << 4)

		mov r13d, r8d
		xor r13d, dword [rsp + 16]

		mov r12d, r11d
		and r12d, 0x3
		xor r12d, r10d
		mov r12d, dword [rdx + r12 * 0x4]
		xor r12d, dword [rsp + 24]			;; (key[r11 & 0x3 ^ e] ^ z)
		add r12d, r13d
		xor eax, r12d
	mov rsp, rbp
	pop rbp
	ret

assign:
	push rbp
	mov rbp, rsp
	mov r12d, dword [rdi + rcx * 0x4]
	add r12d, eax
	mov dword [rdi + rcx * 0x4], r12d
	mov rsp, rbp
	pop rbp
	ret
