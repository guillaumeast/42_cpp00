#include <string>
#include <iostream>
#include <iomanip>
#include "Contact.hpp"
#include "PhoneBook.hpp"
#include "helpers.hpp"

PhoneBook::PhoneBook(): _count(0), _next_index(0) {}

void	PhoneBook::addContact(void)
{
	Contact	contact;

	if (!createContact(contact))
		return ;
	_contacts[_next_index] = contact;
	_next_index = (_next_index + 1) % MAX_CONTACT;
	if (_count < MAX_CONTACT)
		_count++;
	std::cout << "Contact added" << std::endl;
}

bool	PhoneBook::createContact(Contact& out) const 
{
	std::cout << "Contact Details: " << std::endl;
	return (addContactDetailsField(&Contact::setFirstName, "First name", out)
	&& addContactDetailsField(&Contact::setLastName, "Last name", out)
	&& addContactDetailsField(&Contact::setNickname, "Nickname", out)
	&& addContactDetailsField(&Contact::setPhoneNumber, "Phone number", out)
	&& addContactDetailsField(&Contact::setDarkestSecret, "Darkest secret", out));
}

bool	PhoneBook::addContactDetailsField(
			setField 			set,
			const std::string&	field,
			Contact& 			contact) const 
{
	std::string	indent;
	std::string	userInput;

	while (true)
	{
		std::cout << field + ": ";
		if (!std::getline(std::cin, userInput))
			return (false);
		if (!userInput.empty())
			return ((contact.*set)(userInput), true);
		std::cout << "Field cannot be empty, please try again:" << std::endl;
	}
}

void	PhoneBook::searchContact() const 
{
	std::string	userInput;
	int			selectedIndex;

	if (_count == 0)
		std::cout << "The phonebook is empty." << std::endl;
	else
	{
		displayContactsTable();
		std::cout << "Enter the index of the contact to display: ";
		if (!std::getline(std::cin, userInput)
			|| !string_to_int(userInput, selectedIndex)
			|| (selectedIndex < 0 || selectedIndex > static_cast<int>(_count) - 1))
			std::cout << "Invalid index." << std::endl;
		else
			displayContact(_contacts[selectedIndex]);
	}
}

void	PhoneBook::displayContactsTable(void) const
{
	displayContactsRow("Index", "FirstName", "LastName", "Nickname");
	for (size_t i = 0; i < _count; ++i)
		displayContactsRow(
			int_to_string(static_cast<int>(i)),
			_contacts[i].getFirstName(),
			_contacts[i].getLastName(),
			_contacts[i].getNickname());
}

void	PhoneBook::displayContactsRow(
			const std::string&	index,
			const std::string&	firstName,
			const std::string&	lastName,
			const std::string&	nickName) const
{
	std::cout
		<< std::setw(CELL_MAX_CHAR) << formatContactCell(index) << "|"
		<< std::setw(CELL_MAX_CHAR) << formatContactCell(firstName) << "|"
		<< std::setw(CELL_MAX_CHAR) << formatContactCell(lastName) << "|"
		<< std::setw(CELL_MAX_CHAR) << formatContactCell(nickName)
		<< std::endl;
}

std::string	PhoneBook::formatContactCell(const std::string& value) const
{
	if (value.length() > CELL_MAX_CHAR)
		return (value.substr(0, CELL_MAX_CHAR - 1) + ".");
	return (value);
}

void	PhoneBook::displayContact(const Contact& contact) const
{
	std::cout << "First name    : " << contact.getFirstName		() << std::endl;
	std::cout << "Last name     : " << contact.getLastName		() << std::endl;
	std::cout << "Nickname      : " << contact.getNickname		() << std::endl;
	std::cout << "Phone number  : " << contact.getPhoneNumber	() << std::endl;
	std::cout << "Darkest secret: " << contact.getDarkestSecret	() << std::endl;
}
