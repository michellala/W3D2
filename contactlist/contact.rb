require 'pg'
require 'csv'

# Represents a person in an address book.
# The ContactList class will work with Contact objects instead of interacting with the CSV file directly
class Contact

  attr_accessor :first_name, :last_name, :email
  attr_reader :id

@@conn = PG.connect(
  host: 'localhost',
  dbname: 'contactlist',
  user: 'development',
  password:'development'
  )
  
  # Creates a new contact object
  # @param name [String] The contact's name
  # @param email [String] The contact's email address
  def initialize(first_name, last_name, email, id=nil)
    # TODO: Assign parameter values to instance variables.
    @first_name = first_name
    @last_name = last_name
    @email = email
    @id=id
  end

  # Provides functionality for managing contacts in the csv file.
  class << self

    # Opens 'contacts.csv' and creates a Contact object for each line in the file (aka each contact).
    # @return [Array<Contact>] Array of Contact objects
    # def all
      # TODO: Return an Array of Contact instances made from the data in 'contacts.csv'.
      # count = 0
      # CSV.foreach('contacts.csv') do |contact|
      #   puts "#{contact[0]}: #{contact[1].capitalize}, #{contact[2].capitalize}, #{contact[3]} "
      #   count += 1
      # end
      # puts "-----"
      # puts "#{count} Records Total"

    #   @@conn.exec('SELECT * FROM contacts;') do |results|
    #     #results is a collection (array) of records (hashes)
    #     results.map do |contact|
    #       puts contact
    #     end
    #   end
    # end


    def all
     # TODO: Return an Array of Contact instances made from the data in 'contacts.csv'
     puts 'Finding contacts..'
     @@conn.exec('SELECT * FROM contacts ORDER BY id;') do |contacts|
       contacts.map do |c|
         puts "#{c['id']}, #{c['first_name']}, #{c['last_name']}, #{c['email']}"
        end
      end
    end


    def create(first_name, email)
      # TODO: Instantiate a Contact, add its data to the 'contacts.csv' file, and return it.
      @@conn.exec_params("INSERT INTO contacts (first_name,email) VALUES ($1, $2) RETURNING id;", [name,email]) do |contacts|
      @id = contacts[0]["id"]
      end
    puts "Contact created."
    end


    def destroy(id)
      contacts = @@conn.exec_params('DELETE from contacts WHERE id=$1;',[id])
      puts "Contact deleted."
    end
    # Find the Contact in the 'contacts.csv' file with the matching id.
    # @param id [Integer] the contact id
    # @return [Contact, nil] the contact with the specified id. If no contact has the id, returns nil.


    def find(id)
      # TODO: Find the Contact in the 'contacts.csv' file with the matching id.
      results = @@conn.exec_params('SELECT * from contacts WHERE id=$1;' [id])
      if results[0]
        puts "Contact found"
        Contact.new_from_row(results[0])
      else
        puts "Contact not found."
      end
    end
    
    # Search for contacts by either name or email.
    # @param term [String] the name fragment or email fragment to search for
    # @return [Array<Contact>] Array of Contact objects.

    def new_from_row(c)
      Contact.new(c["first_name"],c["email"],c["id"])
    end  

    def save(id)
      puts "Please enter new name"
        first_name = STDIN.gets.chomp
      puts "Please enter new address"
        email = STDIN.gets.chomp
      @@conn.exec_params ("UPDATE contacts SET name=$1, email=$2 WHERE id=$3;", [first_name,email,id])
      puts "Contact updated."
      end
    end

    def search(term)
      # TODO: Select the Contact instances from the 'contacts.csv' file whose name or email attributes contain the search term.
      results=@@conn.exec_params("SELECT * from contacts WHERE first_name LIKE '#{[term}%' OR email LIKE '%#{[term]}%;")
      if contacts[0]
        contacts.map { |contact| p result }
      else
          puts "No results found."
      end

    end



  end

end
