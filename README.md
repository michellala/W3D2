# W3D2


Contact_list
Table of contents
Resources
Object-relational mapping (ORM)
Exercise
Setup: Create a Git branch and a database
Task 1: Database connection
Task 2: Re-implement Contact.all
Task 3: Re-implement Contact.create using Contact#save
Task 4: Re-implement Contact.find
Task 5: Re-implement Contact.search
Task 6: Implement new update command using Contact#save
Task 7: Implement new destroy command using Contact#destroy
Extra 1: Prevent duplicate emails
Extra 2: Multiple phone numbers
Extra 3: Pagination
Extra 4: More methods
Resources
Object-relational mapping (ORM)
Working directly with SQL from Ruby every time you want to talk to a database is cumbersome and annoying. Why? Because in languages like Ruby, we like to work with objects with methods and attributes, not tables, rows and columns.

For this reason, many developers prefer to use an ORM, or object-relational mapping.

Wikipedia has a good overview of ORMs. Read the intro and overview sections only to get an idea of what you're implementing.

Exercise
Given that we already have our app laid out in an object-oriented way and have a Contact class responsible for managing the contacts, we should ideally just be able to modify the Contact class to talk to the contacts table in our database, instead of reading from and writing to a CSV file.

Some changes will need to be made to the contact_list.rb file because using a database will make it possible to implement new features in the Contact class.

Below is a list of features that should ideally be implemented. When a method is preceded by a # it should be an instance method, and when it is preceded by a . it should be a class method.

Instead of implementing these features as you read, consider reading and understanding the entire assignment before proceeding to write any code. Try to plan in your head what will need to change for each feature and you might avoid some rabbit holes.

Setup: Create a Git branch and a database
Within your contacts list app, create and checkout a new branch called something like orm.

git checkout -b orm
This way you can work on and commit/push to a separate branch, and merge back to master later once it's all complete.

Next, create a database for your app.

Important: to create your database (which you've done before), review the week 3 day 2 psql exercise here.

Since you'll be executing only simple SQL statements, I suggest using psql instead of a GUI.

Using psql, create a table in the the database that you just created. Include columns for all the data you need to store for each contact.

CREATE TABLE contacts (
  id    serial NOT NULL PRIMARY KEY,
  name  varchar(40) NOT NULL,
  email varchar(40) NOT NULL
);
Task 1: Database connection
As the application transitions from CSV to a Postgres database for persistence, you'll need to update some dependencies.

The Contact class will now depend on the pg gem (i.e. you'll need to require it to use it).

Since the pg gem is not built-in with Ruby, which means you'll have to get it by including it in your Gemfile. Make sure the Gemfile in your project includes the line gem 'pg' and run bundle exec install in your terminal to make sure that you have all the needed gems installed.

All the orm methods that need to talk to the database need a connection first. Create a connection class method on the Contact class that establishes the connection (using the proper credentials) and returns the connection object. Your other methods will just be able to make use of it. This method shouldn't need to take in any parameters.

Task 2: Re-implement Contact.all
First, we need to to jump to into psql in order to work on our database directly and execute SQL statements in the terminal.

You can do this by going to your terminal and running: psql postgres

Running the code above will take you into the a database called 'postgres' within the psql environment.

Execute multiple INSERT statements through psql to create some dummy records in the contacts table so your app will have contacts to list.

Sidenote: If you don't have a contacts table, go ahead and create one.

Here's an example of a pure SQL insert statement:

INSERT INTO contacts (name, email) VALUES ('Jane Doe', 'jane.doe@example.com');
The code in the the Contact.all method used to read from a CSV file and then instantiate an Array of Contact objects. The method should be changed to select all the contacts from the database using the connection and continue to return an Array of Contact objects.

The SQL that your method executes might look something like the following.

SELECT * FROM contacts;
After making this change, the program should continue to work as it did before, but using the list command should now show the contacts in the database instead of the CSV file.

Task 3: Re-implement Contact.create using Contact#save
The new command is the next one to update. The Contact.create method used to write the contact details to a CSV file, but now it needs to save them to a new row in the database. In order to provide a robust interface for creating and updating contacts, instead of putting the SQL to insert the contact directly inside the Contact.create method, implement a new instance method named Contact#save and call it from within Contact.create on the newly created Contact.

The SQL that the new save method executes might look something like the following.

INSERT INTO contacts (name, email) VALUES ($1, $2);
What's up with the dollar signs?

They're placeholders for parameters that we'd like to use in our query. Basically, it's a way for us to inject values from variables into our SQL query without knowing exactly what the values are.Learn More Here.

You should only use parameterized queries when incorporating user-provided data into your SQL queries. You'll have to use the PG::Connection#exec_params method to make this work.

Why isn't an id being inserted? Databases can simplify things like generating sequential IDs whereas you may have implemented your own solution for the CSV version.

After implementing this change, using the new command on your contact list app should now insert created contacts into the database.

Task 4: Re-implement Contact.find
Finding a contact by id should be more straightforward in this version of the program. The Contact.find method now just needs to execute an SQL statement like the following and convert the resulting data into a new Contact before returning it.

SELECT * FROM contacts WHERE id = $1::int;
There's that parameter placeholder again. And what's the ::int for? It casts the parameter to the correct type before interpolating it into the query. This is how exec_params knows whether to quote the value or not, among other things.

Make sure that your find command continues to work after implementing this change.

Task 5: Re-implement Contact.search
The search command might seem a little daunting at this stage, but it's only a little different from the find method, above. The first difference is that it'll use a different WHERE clause in the query.

The other difference is that every row in the result set should be converted into a Contact object because multiple results might come back, whereas find should only return one.

SELECT name FROM contacts WHERE name LIKE 'Jane Doe';
or you can also do fuzzy matching (non-exact matching), for example, let's say the user entered a search query such as 'Ja' which means we want to pick up users who's names start with 'Ja', such as 'James' or 'Jane'. You can do this with the wildcard character (%):

SELECT name FROM contacts WHERE name LIKE 'Ja%';
Read More About SQL Wildcards

Task 6: Implement new update command using Contact#save
It's time to implement a new command. Your application should now be able to take the command update with a parameter indicating the id of the contact you want to update.

ruby contact_list.rb update 1
The program will then prompt the user for more information about how to update the contact.

In the logic for the update command, you'll need to do a few things. First, you'll have to use Contact.find to get the appropriate Contact. Then you should be able to update the attributes of that contact using code like the following.

the_contact = Contact.find(id)
the_contact.name = new_name
the_contact.email = new_email
the_contact.save
Notice that the Contact#save method is being used here to update that contact, but it was also used to save the record, previously. What logic will you have to have inside the Contact#save method to perform an UPDATE if the contact is already in the database, and an INSERT if it isn't? The SQL that Contact#save runs on the database should be something like the following.

UPDATE contacts SET name = $1, email = $2 WHERE id = $1::int;
Task 7: Implement new destroy command using Contact#destroy
The last missing command is destroy. Add this command so that it takes the id of a contact and then deletes that row from the database. The logic for the destroy command should find the specified contact using the Contact.find method, and then call the Contact#destroy instance method.

the_contact = Contact.find(id)
the_contact.destroy
This will execute a SQL statement like the following.

DELETE FROM contacts WHERE id = $1::int;
The record will be deleted from the database but the object instance will remain in memory in Ruby. This is because method call to an object cannot destroy the object it is called on from memory.

Since the_contact will no longer point to a valid, existing record in the database, using ORM methods like save and destroy (again) will likely cause a postgres error/exception. That's okay for now. We can prevent this by raising our own exception to the caller instead of attempting to execute an invalid query, but let's leave that for now.

Attempting to find contact with the same id now will naturally not yield a contact since it was just deleted.

Extra 1: Prevent duplicate emails
Preventing duplicate emails can now take advantage of the database. What are the available approaches to this feature?

Extra 2: Multiple phone numbers
When the app was using a CSV file all the phone numbers had to be stored in a single cell. In a relational database this doesn't have to be the case. Phone numbers can now be stored in their own table with a foreign key reference to the contact that owns them. If you were to implement this, would you create a separate class to manage phone numbers? How much code could be shared between these classes?

This might cause issues in other parts of the program. How would the update command be able to accommodate changes to phone numbers? Would you select all the phone numbers for a contact whenever they are selected such as in find and all?

Extra 3: Pagination
Pagination is another feature that can take advantage of the database. Postgres allows SELECT queries to specify the limit and offset of the rows desired back. Could the pagination feature be made more memory efficient by not loading all the contacts at once, loading them one page at a time instead?

Extra 4: More methods
Think of the other methods that the Contact class could have for querying the database. For example, Contact.find_by_name(name) and Contact.find_by_email(email) could return the first contact that matches the specified input parameter. How could you share code between these methods?
