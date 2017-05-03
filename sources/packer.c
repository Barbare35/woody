#include <elf.h>
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>

#include <woody.h>
#include <const.h>

static int		st_check_header(Elf64_Ehdr *header)
{
	if (header->e_type != ET_EXEC)
	{
		dprintf(2, "%s\n", ERRB_EX);
		exit(1);
	}
	if (header->e_machine != EM_X86_64)
	{
		dprintf(2, "%s\n", ERRB_ARCH);
		exit(1);
	}
	return (1);
}

static void		*st_mem_proj(char *filename, unsigned int *mem_size)
{
	int			fd;
	int			size;
	void		*ptr;

	if ((fd = open(filename, O_RDONLY)) == -1)
	{
		perror("file error");
		exit(1);
	}
	if ((size = lseek(fd, 0, SEEK_END)) == -1)
	{
		perror("lseek");
		exit(1);
	}
	if ((ptr = mmap(0, size, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0)) == MAP_FAILED)
	{
		perror("mmap error");
		exit(1);
	}
	*mem_size = size;
	close(fd);
	return (ptr);
}

void			packer(char *filename)
{
	void			*bin;
	unsigned int	size;

	bin = st_mem_proj(filename, &size);
	if (((char *)bin)[0] == 0x7F && ((char *)bin)[1] == 0x45 \
		&& ((char *)bin)[2] == 0x4C && ((char *)bin)[3] == 0x46)
	{
		if (((char *)bin)[4] == ELFCLASS64 && st_check_header(bin))
			dprintf(1, "Run packer64\n"); // TODO call packer64
		else if (((char *)bin)[4] == ELFCLASS32)
			dprintf(1, "%s\n", ERRE_32);
		else
			dprintf(1, "%s\n", ERRE_ARCH);
	}
	else
		dprintf(2, "%s\n", ERRE_BIN);
}
