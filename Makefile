SRC_NAME = main.c \
			packer.c

NAME = woody_woodpacker

NAME = woody_woodpacker

OBJ_NAME = $(SRC_NAME:.c=.o)

NAME = woody_woodpacker

SRC_PATH = ./sources/
OBJ_PATH = ./obj/
INC_PATH = ./includes/

CC = gcc
CFLAGS = -Wall -Werror -Wextra
CLIBS =

ifeq ($(DEBUG), basic)
	CFLAGS += -g
endif
ifeq ($(DEBUG), all)
	CFLAGS += -pg -g
endif

SRC = $(addprefix $(SRC_PATH),$(SRC_NAME))
OBJ = $(addprefix $(OBJ_PATH),$(OBJ_NAME))
INC = $(addprefix -I,$(INC_PATH))

all: $(NAME)


$(NAME): $(OBJ)
	$(CC) $(CFLAGS) $(INC) -o $(NAME) $(OBJ) $(CLIBS)


all: $(NAME)

$(OBJ_PATH)%.o: $(SRC_PATH)%.c
	@mkdir $(OBJ_PATH) 2> /dev/null || echo "" > /dev/null
	$(CC) $(CFLAGS) $(INC) -o $@ -c $<

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
