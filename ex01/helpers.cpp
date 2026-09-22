#include "helpers.hpp"
#include <sstream>

std::string	int_to_string(int value)
{
	std::ostringstream	oss;

	oss << value;
	return (oss.str());
}

bool	string_to_int(const std::string& value, int& out)
{
	std::istringstream	iss(value);

	if (!(iss >> out))
		return (false);
	iss >> std::ws;
	return (iss.eof());
}
