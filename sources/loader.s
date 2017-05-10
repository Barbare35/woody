[BITS 64]

global loader:function
global g_loadersize:data

section .text

g_loadersize dd end - loader

loader:

msg db		".... WOODY ....", 10

			push rbp
			mov rbp, rsp

			push rdi
			push rsi
			push rdx
			push rax

			mov rdi, 1
			lea rsi, [rel msg]
			mov rdx, 16
			mov rax, 1
			syscall

			pop rax
			pop rdx
			pop rsi
			pop rdi

			mov rsp, rbp
			pop rbp
			jmp 0xFFFFFFFF		;temporary address, replace by packer->jmp_addr
end:
