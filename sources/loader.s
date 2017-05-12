[BITS 64]

global loader:function
global g_loadersize:data
global g_loaderoff:data

section .text

g_loadersize dd end - loader
g_loaderoff dd loader_run - loader

loader:

msg db		".... WOODY ....", 10

decrypt_xxtea:
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
		mov r9, rax						;; Save quantum
		pop rdx
		;; END QUANTUM CALCULATE

		;; Calcul SUM
		push rdx
		mov eax, 0x9e3779b9
		mov r8, r9
		mul r8
		mov r8d, eax					;; save sum
		pop rdx

	.prepare_buffer:
		mov r15, rsi
		dec r15
		mov r10d, dword [rdi + r15 * 4]		;; z_buffer
		push r10
		xor r10, r10
		mov r10d, dword [rdi]			;; y_buffer
		push r10

	.loop:
		cmp r8d, 0
		je .end_loop
		mov r10d, r8d
		shr r10d, 0x2
		and r10d, 0x3
		mov r11, rsi
		dec r11

	.snd_loop:
		cmp r11, 0				;; while r11 > 0
		je .end_snd_loop
		;; mov y_buffer
		mov r15, r11
		dec r15
		mov r12d, dword [rdi + r15 * 0x4] ;; on prepare z_buffer
		mov dword [rsp + 8], r12d

		;; algo
		call algo_test

		;; Assign new character
		mov rcx, r11
		call assign_neg

		;; move y_buffer
		mov r12d, dword [rdi + r11 * 0x4]
		mov dword [rsp], r12d
		dec r11
		jmp .snd_loop

	.end_snd_loop:
		;; reset z_buffer
			mov r12, rsi
			dec r12
			mov r12d, dword [rdi + r12 * 0x4]
			mov dword [rsp + 8], r12d	;; z_block = block[len - 1]
		;; algo
			call algo_test
		;; Assign new character
			mov rcx, 0
			call assign_neg

		;; reset y_buffer
			mov r12d, dword [rdi]
			mov dword [rsp], r12d
		sub r8d, 0x9e3779b9
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

algo_test:
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

assign_neg:
	push rbp
	mov rbp, rsp
	mov r12d, dword [rdi + rcx * 0x4]
	sub r12d, eax
	mov dword [rdi + rcx * 0x4], r12d
	mov rsp, rbp
	pop rbp
	ret

loader_run:
			push rbp
			mov rbp, rsp

			push rdi
			push rsi
			push rdx
			push rax
			push rbx

			xor rbx, rbx
			mov rbx, 0x42000000DE
			push rbx
			mov rbx, 0x27000000AB
			push rbx
			mov rdx, rsp
			xor rsi, rsi
			mov esi, [rel sizecrypt]
			xor rdi, rdi
			mov edi, [rel addr]
			call decrypt_xxtea

			pop rbx
			pop rbx

			mov rdi, 1
			lea rsi, [rel msg]
			mov rdx, 16
			mov rax, 1
			syscall

			pop rbx
			pop rax
			pop rdx
			pop rsi
			pop rdi

			mov rsp, rbp
			pop rbp
			jmp 0xFFFFFFFF		;temporary address, replace by packer->jmp_addr
	addr		dd	0x00		;address start .text, replace by packer->offset_text
	sizecrypt 	dd	0x00		;size to decrypt, replace by return st_crypt
end:
