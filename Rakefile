require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb', 'test/*/**_test.rb']
  t.verbose = true
end

# The tasks in this namespace manage class definitions in the repository.
#
# I've made a task for each file we want to commit to the repository.  This
# may be overkill in a bigger project, but it makes it easier to see each
# step, and to experiment with different orderings, etc. to see what the
# dependencies are.
namespace :commit do
  desc "Commit Persistable and the test fixtures to the repository"
  task :all => [:persistable, :book]

  desc "Commit the Persistable module (and its dependencies) to the repository"
  task :persistable do
    sh %{ maglev-ruby -Mcommit -Ilib -e 'require "persistable.rb"' }
  end

  desc "Commit the test fixture classes (Book) to the repository."
  task :book do
    sh %{ maglev-ruby -Mcommit -Itest -e 'require "book.rb"' }
  end
end

# The tasks in this namespace are for testing.
#
# I do not use the Rake::TestTask, as typically, even with MagLev
# installed, typing "rake ..." at the command line will invoke the MRI
# version of Rake, and the TestTask will run the tests using the Ruby it
# was invoked with (i.e., there is danger that you'll attempt to run all of
# your Test::Unit stuff under MRI rather than MagLev...).
namespace :tests do
  desc "Run a simple test to see if Persistable in fact makes a class persistent"
  task :basic do
    # Just to separate concerns (make the order of things clear), I've
    # broken the test into several stages.  You could, of course, combine
    # then into fewer steps, but I just wanted to make logical each step
    # clear, and stand on its own for clarity.

    # Step One:
    #
    # Commit classes to repository. Before running "rake test:basic", you
    # should have committed Persistable and Book to the repository by
    # doing:
    #
    #  rake commit:all
    #
    # This needs to be done only once per repository, or when either
    # Persistable or Book changes.

    # Step Two:
    #
    # In a new VM, Test that Book is properly persisted and it has all
    # features we expect.  We do this in a different VM than the one that
    # committed the code, so that we see only the persistent state of the
    # Book class.
    sh %{ maglev-ruby test/book_test.rb }

    # Step Three:
    #
    # Create test fixtures: In a new VM, Create some instances of Book, and
    # commit them to the repository.  Also creates some instances but do
    # not commit them.
    sh %{ maglev-ruby test/book_instances.rb }

    # Step Four
    #
    # In a new VM, Test that the instances we expect were persisted.
    # In the first VM, we commit our test fixtures (instances of Book)
    # repository.  The book.rb file does only one thing: define the Book
    # class.  It doesn't concern itself with persistence at all.  See
    # comments there for a fuller discussion.
    sh %{ maglev-ruby test/book_instances_test.rb }
  end
end
