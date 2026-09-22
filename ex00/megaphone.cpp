#include <iostream>
#include <string>
#include <cctype>
#include <cstdlib>

static void	print_default_message()
{
	std::cout << "* LOUD AND UNBEARABLE FEEDBACK NOISE *" << std::endl;
}

static void	print_upper_string(std::string str)
{
	for (std::string::size_type	i = 0; i < str.size(); ++i)
		str[i] = static_cast<char>(std::toupper(static_cast<unsigned char>(str[i])));
	std::cout << str;
}

static void	print_upper_args(int argc, char **argv)
{
	std::string	str;

	for (int i = 1; i < argc; ++i)
	{
		str = argv[i];
		print_upper_string(str);
	}
	std::cout << std::endl;
}

int	main(int argc, char **argv)
{
	try
	{
		std::cout.exceptions(std::ios::failbit | std::ios::badbit);
		if (argc < 2)
			print_default_message();
		else
			print_upper_args(argc, argv);
	}
	catch (...)
	{
		return (EXIT_FAILURE);
	}
	return (EXIT_SUCCESS);
}
