require 'set'
require 'forwardable'

Set.maglev_persistable if defined? Maglev

module Persistable

  # A store should be able to, uh, store objects. Also:
  # - should provide an insertion mechanism
  # - should provide a deletion mechanism
  # - should provide a querying mechanism
  # - should not accept duplicates
  # - should be Set
  # Ok, so that last one isn't a requirement. Gosh darned, it's the solution!

  module ClassMethods
    # Get all those yummy querying methods
    include Enumerable
    extend Forwardable

    # Set that keeps all instances
    def store
      @store ||= begin
        # The code should at least run on standard MRI, even if it doesn't really
        # provide persistence then.
        if defined? Maglev
          # Flag the class as persistable by Maglev
          maglev_persistable
          Maglev::PERSISTENT_ROOT[self] ||= Set.new 
        else
          Set.new
        end
      end
    end

    # Give access to SOME of @store's instance methods.
    # May want to expand this list at some point.
    # Most of the remaining useful ones are shared with Array, so they can be used
    # after calling #to_a first.
    def_delegators :store, :classify, :clear, :delete, :delete?, :delete_if, :each, :empty?, :include?, :size, :to_a

    # WARNING: objects stored in the set are not stored in order
    # We can get around that by #sort-ing on a timestamp attribute, 
    # but lets avoid that behaviour by default
    alias all to_a
    alias delete_all clear
  end
  
  # Store the instance in the Set
  def persist
    self.class.store.add?(self) ? true: false
  end

  # Remove the instance from the Set (it's being a bad actor or something)
  def desist
    self.class.delete self
  end

  # In case we want to check if an object is already found in the set
  def persistent?
    self.class.include? self
  end

  def transient?
    not persistent?
  end

  # Be sure to call super afterwards to allow for other hooks
  def self.included(klass)
    klass.extend ClassMethods
    super
  end

end