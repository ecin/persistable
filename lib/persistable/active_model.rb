require "persistable"

module Persistable
  module ActiveModel
    module ClassMethods
      def to_param
        raise NotImplementedError, "please implement in subclass"
      end

      # Note: This lookup is in O(n). You might considere a data structure based on a hash
      # for large sets, as it has a lookup in O(1). However, that approach would not handle
      # sudden changes of to_param.
      def find(param)
        detect { |e| e.to_param == param }
      end

      def new(options = {})
        super().tap { |r| options.each { |k,v| r.send "#{k}=", v } }
      end

      def create(options = {})
        new(options).tap { |r| r.save }
      end

      alias create! create

      def method_missing(name, *args, &block)
        return detect { |e| e.send($1) == args.first } if name.to_s =~ /^find_by_(.+)$/
        super
      end

    end

    def new_record?
      transient?
    end

    def save
      persist
    end

    alias save! save

    def destroy
      desist
    end

    def tap
      yield(self)
      self
    end

    def self.included(klass)
      klass.send :include, Persistable
      klass.extend ClassMethods
      super
    end
  end
end