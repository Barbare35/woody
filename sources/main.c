#include <stdio.h>

#include <woody.h>

int				main(int ac, char **av)
{
	if (ac == 2)
		packer(av[1]);
	else
		dprintf(1, "%s <filename>\n", av[0]);
	return (0);
}
