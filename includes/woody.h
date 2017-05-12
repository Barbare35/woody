#ifndef WOODY_H
# define WOODY_H

# include <elf.h>
# include <stdint.h>

struct			s_pack
{
	void		*bin;
	uint32_t	size;
	Elf64_Ehdr	*headelf;
	Elf64_Phdr	*headprog;
	Elf64_Shdr	*headsec;
	uint32_t	last_ptload;
	uint32_t	last_secload;
	uint32_t	last_offload;
	uint32_t	last_entry;
	uint32_t	align;
	uint32_t	jmp_addr;
	uint32_t	loader_offset;
	uint32_t	offset_text;
};

typedef struct s_pack	t_pack;

/*
 * packer.c
*/
void			packer(char *filename);

/*
 * packer64.c
*/
void			packer64(void *bin, uint32_t size);

/*
 * pack64.c
*/
uint32_t		p64_get_last_ptload(t_pack *packer);
uint32_t		p64_get_last_secload(t_pack *packer);
void			p64_change_headprog_flags(t_pack *packer);
void			p64_change_header(t_pack *packer);
uint32_t		p64_get_offset_text_load(t_pack *packer);

/*
 * loader.s
*/
void			loader(void);

/*
 * algo_crypt_xxtea.s
*/
void			crypt_xxtea(uint32_t *block, uint32_t len, uint32_t *key);

#endif
