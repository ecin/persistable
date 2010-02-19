# Test persistent aspects of the Book class. Assumes rake commit:all

require 'test/unit'

# Note: We do not need to require Book, as it has been persisted to the
# repository, i.e., it has been permanently required for us.

class BookTest < Test::Unit::TestCase

  def test_book_class_existence
    assert_not_nil(Book, "Expected Book class to exist")
  end

  def test_book_ancestors
    ancestors = Book.ancestors
    [Persistable, Enumerable, Struct].each do |klass|
      assert(ancestors.include?(klass), "Expecting #{klass} to be ancestor of Book")
    end
  end

  def test_book_persitence
    # We already know its persistent...but
    assert(Book.maglev_persistable?)
    assert(Book.maglev_instances_persistable?)
  end
end
