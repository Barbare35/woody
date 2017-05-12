SRC_NAME = main.c \
			packer.c \
			packer64.c \
			pack64.c

SRC_ASM = loader.s \
			algo_crypt_xxtea.s

OBJ_NAME = $(SRC_NAME:.c=.o)
OBJ_ASM = $(SRC_ASM:.s=.o)

NAME = woody_woodpacker

SRC_PATH = ./sources/
OBJ_PATH = ./obj/
INC_PATH = ./includes/

CC = gcc
CFLAGS = -Wall -Werror -Wextra
CLIBS =

AC = nasm
AFLAGS = -f elf64

ifeq ($(DEBUG), basic)
	CFLAGS += -g
endif
ifeq ($(DEBUG), all)
	CFLAGS += -pg -g
endif

SRC = $(addprefix $(SRC_PATH),$(SRC_NAME))
OBJ = $(addprefix $(OBJ_PATH),$(OBJ_NAME))
INC = $(addprefix -I,$(INC_PATH))

SRCA = $(addprefix $(SRC_PATH),$(SRC_ASM))
OBJA = $(addprefix $(OBJ_PATH),$(OBJ_ASM))

$(NAME): $(OBJ) $(OBJA)
	$(CC) $(CFLAGS) $(INC) -o $(NAME) $(OBJ) $(OBJA) $(CLIBS)

all: $(NAME)

$(OBJ_PATH)%.o: $(SRC_PATH)%.c
	@mkdir $(OBJ_PATH) 2> /dev/null || echo "" > /dev/null
	$(CC) $(CFLAGS) $(INC) -o $@ -c $<

$(OBJ_PATH)%.o: $(SRC_PATH)%.s
	$(AC) $(AFLAGS) -o $@ $<

clean:
	rm -f $(OBJ)
ifneq ($(OBJ_PATH), ./)
	rm -rf $(OBJ_PATH)
endif

fclean: clean
	rm -f $(NAME)

mrproper: fclean

re: fclean all

.PHONY: all clean fclean mrproper re
