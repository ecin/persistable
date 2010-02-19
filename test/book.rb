# This file defines a simple class and includes Persistable into that class
# so that we can test the effectiveness of Persistable.
#
# We assume that the Persistable module has already been persisted to the
# repository, so we do NOT need to require it here...
#
# require 'persistable'

class Book < Struct.new(:title, :author)
  include Persistable

  attr_accessor :read
  alias read? read

  def to_s
    title + ' by ' + author
  end
end
