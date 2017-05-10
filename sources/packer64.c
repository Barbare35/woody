#include <elf.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <woody.h>
#include <const.h>

extern uint32_t	g_loadersize;

static void			st_write_file(t_pack *packer, Elf64_Shdr *new_headsec, \
									void *endsecoff, uint32_t secsz)
{
	int			fd;
	uint32_t	i;
	void		*end;

	i = 0;
	end = packer->bin + packer->loader_offset;
	if ((fd = open(NAME_OUT, O_RDWR | O_CREAT, 0744)) == -1)
	{
		dprintf(2, "%s\n", ERRE_CREATE_FILE);
		exit(1);
	}
	write(fd, packer->headelf, packer->loader_offset);
	while (i < packer->align)
	{
		write(fd, "\x00", 1);
		++i;
	}
	write(fd, &loader, g_loadersize - 4);
	write(fd, &packer->jmp_addr, 4);
	write(fd, end, (packer->size - packer->loader_offset) - \
				(((packer->headelf->e_shnum - 1) - packer->last_secload) * \
				sizeof(Elf64_Shdr)));
	write(fd, &new_headsec, sizeof(Elf64_Shdr));
	write(fd, endsecoff, packer->size - secsz);
	close(fd);
}

static void			st_prepare_file(t_pack *packer, Elf64_Shdr *new_headsec)
{
	void		*endsecoff;
	uint64_t	secsz;

	endsecoff = packer->bin + packer->headelf->e_shoff + \
				(packer->headelf->e_shentsize * packer->last_secload);
	secsz = packer->headelf->e_shoff + (packer->headelf->e_shentsize * \
				(packer->last_secload));
	p64_change_header(packer);
	packer->jmp_addr = ((packer->headprog[packer->last_ptload].p_vaddr + \
						packer->headprog[packer->last_ptload].p_filesz) - \
						packer->last_entry) * -1;
	st_write_file(packer, new_headsec, endsecoff, secsz);
}

void				packer64(void *bin, uint32_t size)
{
	t_pack			packer;
	Elf64_Shdr		new_headsec;

	packer.bin = bin;
	packer.size = size;
	packer.headelf = (Elf64_Ehdr *)bin;
	packer.headprog = (Elf64_Phdr *)(bin + packer.headelf->e_phoff);
	packer.headsec = (Elf64_Shdr *)(bin + packer.headelf->e_shoff);
	packer.last_ptload = p64_get_last_ptload(&packer);
	packer.last_secload = p64_get_last_secload(&packer);
	packer.last_entry = packer.headelf->e_entry;
	packer.align = packer.headprog[packer.last_ptload].p_memsz - \
					packer.headprog[packer.last_ptload].p_filesz;
	packer.loader_offset = packer.headprog[packer.last_ptload].p_offset + \
							packer.headprog[packer.last_ptload].p_filesz;
	new_headsec = p64_add_headsec(&packer);
	p64_change_headprog_flags(&packer);
	st_prepare_file(&packer, &new_headsec);
}
