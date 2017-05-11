#include <stdint.h>
#include <elf.h>
#include <woody.h>
#include <const.h>

extern uint32_t	g_loadersize;

uint32_t		p64_get_last_ptload(t_pack *packer)
{
	int			i;
	uint32_t	v_addr;
	uint32_t	last_ptload;
	Elf64_Phdr	*headprog;

	i = 0;
	v_addr = 0;
	last_ptload = 0;
	headprog = packer->headprog;
	while (i < packer->headelf->e_phnum)
	{
		if (headprog[i].p_type == PT_LOAD && \
			v_addr <= (headprog[i].p_vaddr + headprog[i].p_memsz))
		{
			v_addr = headprog[i].p_vaddr + headprog[i].p_memsz;
			last_ptload = i;
		}
		++i;
	}
	return (last_ptload);
}

uint32_t		p64_get_last_secload(t_pack *packer)
{
	int			i;
	uint32_t	last_secload;
	Elf64_Shdr	*headsec;

	i = 0;
	last_secload = 0;
	headsec = packer->headsec;
	while (i < packer->headelf->e_shnum)
	{
		if (headsec[i].sh_addr + headsec[i].sh_size >= \
			packer->headprog[packer->last_ptload].p_vaddr + \
			packer->headprog[packer->last_ptload].p_memsz)
		{
			last_secload = i;
		}
		++i;
	}
	return (last_secload);
}

void			p64_change_headprog_flags(t_pack *packer)
{
	int			i;
	Elf64_Phdr	*headprog;

	i = 0;
	headprog = packer->headprog;
	while (i < packer->headelf->e_phnum)
	{
		if (headprog[i].p_type == PT_LOAD)
			headprog[i].p_flags = PF_X | PF_W | PF_R;
		++i;
	}
}

void			p64_change_header(t_pack *packer)
{
	int			i;

	i = 0;
	while (i < packer->headelf->e_shnum)
	{
		if (packer->headsec[i].sh_offset >= packer->loader_offset)
		{
			packer->headsec[i].sh_offset += (g_loadersize + packer->align);
			packer->headsec[i].sh_addr += (g_loadersize + packer->align);
		}
		++i;
	}
	packer->headelf->e_shoff += (g_loadersize + packer->align);
	packer->headelf->e_entry = (packer->headprog[packer->last_ptload].p_vaddr +\
							packer->headprog[packer->last_ptload].p_filesz) +\
							packer->align + LOAD_MSG_LEN;
	packer->headprog[packer->last_ptload].p_memsz += g_loadersize;
	packer->headprog[packer->last_ptload].p_filesz = \
								packer->headprog[packer->last_ptload].p_memsz;
}
