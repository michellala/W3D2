require 'csv'


# Represents a person in an address book.
# The ContactList class will work with Contact objects instead of interacting with the CSV file directly
class Contact

  attr_accessor :name, :email
  
  # Creates a new contact object
  # @param name [String] The contact's name
  # @param email [String] The contact's email address
  def initialize(first_name, last_name, email)
    # TODO: Assign parameter values to instance variables.
    @first_name = first_name
    @last_name = last_name
    @email = email
  end

  # Provides functionality for managing contacts in the csv file.
  class << self

    # Opens 'contacts.csv' and creates a Contact object for each line in the file (aka each contact).
    # @return [Array<Contact>] Array of Contact objects
    def all
      # TODO: Return an Array of Contact instances made from the data in 'contacts.csv'.
      count = 0
      CSV.foreach('contacts.csv') do |contact|
        puts "#{contact[0]}: #{contact[1].capitalize}, #{contact[2].capitalize}, #{contact[3]} "
        count += 1
      end
      puts "-----"
      puts "#{count} Records Total"
    end

    # Creates a new contact, adding it to the csv file, returning the new contact.
    # @param name [String] the new contact's name
    # @param email [String] the contact's email
    def create(first_name, last_name, email)
      # TODO: Instantiate a Contact, add its data to the 'contacts.csv' file, and return it.
      contact = Contact.new(first_name, last_name, email)
      number_of_contacts = CSV.read('contacts.csv').length
      CSV.open('contacts.csv', 'a+') do |contact|
        contact << [number_of_contacts + 1, first_name, last_name, email]
      end
    end
    
    # Find the Contact in the 'contacts.csv' file with the matching id.
    # @param id [Integer] the contact id
    # @return [Contact, nil] the contact with the specified id. If no contact has the id, returns nil.
    def find(id)
      # TODO: Find the Contact in the 'contacts.csv' file with the matching id.
      CSV.foreach('contacts.csv') do |contact|
        if contact[0].to_i == id
          puts contact
        else
          puts "No Contact Found"
          break
        end

      end

    end
    
    # Search for contacts by either name or email.
    # @param term [String] the name fragment or email fragment to search for
    # @return [Array<Contact>] Array of Contact objects.
    def search(term)
      # TODO: Select the Contact instances from the 'contacts.csv' file whose name or email attributes contain the search term.
      count = 0
      CSV.foreach('contacts.csv') do |contact|
        if contact.include?(term)
          puts "#{contact[0]}: #{contact[1].capitalize}, #{contact[2].capitalize}, #{contact[3]}"
          count += 1
        end
      end
      puts "-----"
      puts "#{count} Record Total"
    end

  end

end
