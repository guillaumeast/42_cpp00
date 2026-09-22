#include "Contact.hpp"

void	Contact::setFirstName(const std::string& firstName)
{
	_firstName = firstName;
}

void	Contact::setLastName(const std::string& lastName)
{
	_lastName = lastName;
}

void	Contact::setNickname(const std::string& nickname)
{
	_nickname = nickname;
}

void	Contact::setPhoneNumber(const std::string& phoneNumber)
{
	_phoneNumber = phoneNumber;
}

void	Contact::setDarkestSecret(const std::string& darkestSecret)
{
	_darkestSecret = darkestSecret;
}

const std::string&	Contact::getFirstName() const
{
	return (_firstName);
}

const std::string&	Contact::getLastName() const
{
	return (_lastName);
}

const std::string&	Contact::getNickname() const
{
	return (_nickname);
}

const std::string&	Contact::getPhoneNumber() const
{
	return (_phoneNumber);
}

const std::string&	Contact::getDarkestSecret() const
{
	return (_darkestSecret);
}
