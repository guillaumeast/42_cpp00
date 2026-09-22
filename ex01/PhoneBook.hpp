#ifndef PHONEBOOK_HPP
# define PHONEBOOK_HPP

# include "Contact.hpp"

# define MAX_CONTACT	8
# define CELL_MAX_CHAR	10

typedef void (Contact::*setField)(const std::string& value);

class PhoneBook
{
	public:
		PhoneBook();

		void	addContact(void);
		void	searchContact(void) const;

	private:
		size_t	_count;
		size_t	_next_index;
		Contact	_contacts[MAX_CONTACT];

		bool	createContact(Contact& out) const;
		bool	addContactDetailsField(
					setField 			set,
					const std::string&	field,
					Contact& 			contact) const;
		
		void		displayContactsTable(void) const;
		void		displayContact(const Contact& contact) const;
		std::string	displayContactCell(const std::string& value) const;
		void		displayContactsRow(
						const std::string&	index,
						const std::string&	firstName,
						const std::string&	lastName,
						const std::string&	nickName) const;
};

#endif
