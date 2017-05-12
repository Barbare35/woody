#include <elf.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <woody.h>
#include <const.h>

extern uint32_t	g_loadersize;

static void			st_write_file(t_pack *packer, uint32_t size)
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
	write(fd, &loader, g_loadersize - 12);
	write(fd, &packer->jmp_addr, 4);
	write(fd, &packer->offset_text, 4);
	write(fd, &size, 4);
	write(fd, end, packer->size - packer->loader_offset);
	close(fd);
}

static int			st_cmp(char *str1, char *str2)
{
	while (*str1 && *str2)
	{
		if (*str1 != *str2)
			return (1);
		str1++;
		str2++;
	}
	if (*str1 == 0x00 && *str2 == 0x00)
		return (0);
	return (1);
}

static uint32_t		st_crypt(t_pack *packer)
{
	int			i;
	uint32_t	key[4] = {0xAB, 0x27, 0xDE, 0x42};
	char		*strtable;
	Elf64_Shdr	*headsec;

	i = 0;
	headsec = packer->headsec;
	strtable = packer->bin + headsec[packer->headelf->e_shstrndx].sh_offset;
	while (i < packer->headelf->e_shnum)
	{
		if (st_cmp(strtable + headsec[i].sh_name, ".text") == 0)
		{
			crypt_xxtea(packer->bin + headsec[i].sh_offset, \
						headsec[i].sh_size / 4, key);
			packer->offset_text += headsec[i].sh_offset;
			return (headsec[i].sh_size / 4);
		}
		++i;
	}
	return (0);
}

void				packer64(void *bin, uint32_t size)
{
	t_pack			packer;
	uint32_t		cryptsz;

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
	packer.offset_text = p64_get_offset_text_load(&packer);
	cryptsz = st_crypt(&packer);
	p64_change_headprog_flags(&packer);
	p64_change_header(&packer);
	packer.jmp_addr = ((packer.headprog[packer.last_ptload].p_vaddr + \
						packer.headprog[packer.last_ptload].p_filesz) - \
						packer.last_entry) * -1;
	packer.jmp_addr += SIZE_VAR_LOADER;
	st_write_file(&packer, cryptsz);
}
