# Test persistent instances of the Book class.
# Assumes rake commit:all, and that book_instances.rb has been run

require 'test/unit'

# Note: We do not need to require Book, as it has been persisted to the
# repository, i.e., it has been permanently required for us.

class BookInstancesTest < Test::Unit::TestCase

  def test_expected_fixtures
    assert_equal(4, Book.count)
  end

  def test_book_instance_methods
    # Kind of awkward to get one book...
    a_book = Book.store.detect {|b| true }
    assert_not_nil(a_book)
    assert(! a_book.read?)
    assert_not_nil(a_book.to_s)
    assert_not_nil(a_book.title)
    assert_not_nil(a_book.author)
    great_american_novel = Book.store.find { |b| b.title == "The Great American Novel"}
    assert_nil(great_american_novel)
  end

  def test_persistable_class_methods
    # Ensure the class side methods on Book got installed persistently
    [:store, :classify, :clear, :delete, :delete?, :delete_if,
     :each, :empty?, :size, :to_a].each do |m|
      assert(Book.respond_to?(m), "Expected class method '#{m}' on Book")
    end

    # Make sure you can invoke some of them
    assert(! Book.empty?)
  end
end
