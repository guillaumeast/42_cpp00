NAME		:= phonebook

CXX			:= c++
CXXFLAGS	:= -Wall -Wextra -Werror -std=c++98
INCLUDES	:= .
SRCS		:= main.cpp \
			   Contact.cpp \
			   PhoneBook.cpp \
			   helpers.cpp

OBJ_DIR		:= obj
OBJS		:= $(SRCS:%.cpp=$(OBJ_DIR)/%.o)
DEPS		:= $(OBJS:.o=.d)

CPPFLAGS	:= $(addprefix -I,$(INCLUDES))
DEPFLAGS	:= -MMD -MP

RM			:= rm -f

all: $(NAME)

$(NAME): $(OBJS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $@

$(OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(DEPFLAGS) -c $< -o $@

clean:
	$(RM) -r $(OBJ_DIR)

fclean: clean
	$(RM) $(NAME)

re:
	$(MAKE) fclean
	$(MAKE) all

-include $(DEPS)

.PHONY: all clean fclean re
