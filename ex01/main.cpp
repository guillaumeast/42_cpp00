#include <string>
#include <iostream>
#include "PhoneBook.hpp"

int	main(void)
{
	PhoneBook	phoneBook;
	std::string	userInput;

	while (true)
	{
		std::cout << "Enter a command (ADD, SEARCH, EXIT): ";
		if (!std::cout || !std::getline(std::cin, userInput))
			return (EXIT_FAILURE);
		else if	(userInput == "ADD")
			phoneBook.addContact();
		else if (userInput == "SEARCH")
			phoneBook.searchContact();
		else if (userInput == "EXIT")
			return (EXIT_SUCCESS);
		else
			std::cout << "Invalid command" << std::endl;
	}
}
