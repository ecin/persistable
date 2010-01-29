module Persistable

  # A store should be able to, uh, store objects. Also:
  # - should provide a deletion mechanism
  # - should provide a querying mechanism
  # - should not accept duplicates
  # - should be Set
  # Ok, so that last one isn't a requirement. Gosh darned, it's the solution!

  require 'set'
  
  def self.included(klass)
    klass.class_eval do
      
      # The code should at least run on standard MRI, even if it doesn't really
      # provide persistence then.
      if defined?(Maglev)
        # Flag the class as persistable by Maglev
        # The documentation mentions #maglev_persistable=(true)
        # The documentation is also wrong
        self.maglev_persistable
        @@store = ( Maglev::PERSISTENT_ROOT[self] ||= Set.new )
      else
        @@store ||= Set.new
      end
       
      # Get all those yummy querying methods.
      extend Enumerable
       
      def self.each(&block)
        @@store.each &block
      end

      # Not #length or #size since #count seems closer to the search domain
      def self.count
        @@store.size
      end

      # WARNING: objects stored in the set are not stored in order
      # We can get around that by #sort-ing on a timestamp attribute, 
      # but lets avoid that behaviour by default
      def self.all
        @@store.to_a
      end

      def self.delete_all
        @@store -= @@store
      end
          
      # Store the instance in the Set
      def persist
        @@store.add?(self) ? true: false
      end
      
      # Remove the instance from the Set (it's being a bad actor or something)
      def desist
        @@store.delete self
      end
      
      # In case we want to check if an object is already found in the set
      def persistent?
        @@store.include? self
      end
      
      def transient?
        not persistent?
      end
      
    end
  end
    
end