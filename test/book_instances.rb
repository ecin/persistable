# This is not a test case.  This file clears old test fixtures from the DB
# and then sets up new test fixtures and commits them.  This is intended to
# be run from a different VM than the actual test cases that depend on
# them.

# Assumes the Book class is already saved in the repository.

# Clear any fixtures from a previous run.
Book.delete_all
Maglev.commit_transaction

raise "Lingering instances of book" unless Book.count == 0


# Add some fixtures and commit
Book.new("Satan, Cantor, and Infinity", "Raymond Smullyan").persist
Book.new("Surely You're Joking, Mr. Feynman!", "Richard P. Feynman").persist # => true
Book.new("Green Eggs and Ham", "Dr. Seuss").persist # => true
Book.new("Cat in the Hat", "Dr. Seuss").persist # => true

# Commit instances to the repository
Maglev.commit_transaction

raise "Wrong number of instances" unless Book.count == 4

# Create a book instance, but do not persist it to the repository
Book.new("The Great American Novel", "A. Scott").persist





