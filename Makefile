# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: mbarbari <mbarbari@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/04/07 16:55:33 by mbarbari          #+#    #+#              #
#    Updated: 2017/04/11 13:52:46 by barbare          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

CC ?= clang
CX ?= clang++

NAME = woody_woodpacker

CFLAGS += -Wall -Wextra -Werror

SOURCES_FILES = ./sources
HEADERS_FILES = ./includes
OBJECTS_FILES = ./objects

LIBSDIR = ../libs/libft
LIBS = -L$(LIBSDIR) -lft
LIBSNAME = libft.a
LIBFT = $(LIBSDIR)/$(LIBSNAME)

INC = -I./includes -I$(LIBSDIR)/include

CLI_SRCS = 	$(SOURCES_FILES)/main.c \

CLI_OBJS = $(patsubst $(SOURCES_FILES)/%.c,$(OBJECTS_FILES)/%.o,$(CLI_SRCS))

SRC_INCLUDE = $(HEADERS_FILES)/woody.h \

RM ?= rm -f
MKDIR ?= mkdir
CD ?= cd

all: $(NAME)

install:
	mkdir -p $(SOURCES_FILES)
	mkdir -p $(HEADERS_FILES)
	mkdir -p $(OBJECTS_FILES)

print-% : ; $(info $* is $(flavor $*) variable set to [$($*)]) @true

$(NAME): $(LIBFT) $(CLI_OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(INC) $(LIBS)

$(OBJECTS_FILES)/%.o: $(SOURCES_FILES)/%.c $(SRC_INCLUDE)
	$(MKDIR) -p $(dir $@)
	$(CC) -c $(CFLAGS) $(INC) $< -o $@

$(LIBFT):
	$(MAKE) -C $(LIBSDIR)

clean:
	$(RM) $(CLI_OBJS)

fclean: clean
	$(RM) cli
	$(RM) $(CLI_OBJS)
	$(MAKE) -C $(LIBSDIR) fclean

re: fclean all

.PHONY: clean fclean re all
