require 'set'
require 'forwardable'

Set.maglev_persistable if defined? Maglev

module Persistable
  
  # The Persistable module itself should be flagged as persistable
  self.class_eval { maglev_persistable }

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
          Maglev::PERSISTENT_ROOT[self] ||= Set.new 
        else
          warn "Objects will not be persitent, as this is not Maglev."
          Set.new
        end
      end
    end

    # Give access to SOME of @store's instance methods.
    # May want to expand this list at some point.
    # Most of the remaining useful ones are shared with Array, so they can be used
    # after calling #to_a first.
    def_delegators :store, :classify, :clear, :delete, :delete?, :delete_if, :each, :empty?, :size, :to_a

    # WARNING: objects stored in the set are not stored in order
    # We can get around that by #sort-ing on a timestamp attribute, 
    # but lets avoid that behaviour by default
    alias all to_a
    alias delete_all clear
  end
  
  # Store the instance in the Set
  def persist
    !!self.class.store.add?(self)
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
    klass.class_eval do
      # Flag the class as persistable by Maglev
      self.maglev_persistable
      class << self
        alias original_include? include?
      end
    end
    klass.extend ClassMethods
    klass.instance_eval do
      # We don't want to overwrite Module#include?, 
      # so only delegate #include if the argument 
      # isn't a Module.
      def include?(arg)
        arg.is_a?(Module) ? original_include?(arg) : store.include?(arg)
      end
    end
    super
  end

end