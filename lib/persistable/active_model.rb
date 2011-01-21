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

      def new(options  = {})
        super().tap { |r| options.each { |k,v| r.send "#{k}=", v } }
      end

      def create(options  = {})
        new(options).tap { |r| r.save }
      end
      
      def model_name
        potential_name = name if self.respond_to? :name
        potential_name ||= to_s
        class << potential_name
          %w[human partial_path singular plural].each do |meth|
            next if self.respond_to? meth
            define_method(meth) { self }
          end
        end
        potential_name
      end

      alias create! create

      def method_missing(name, *args, &block)
        return detect { |e| e.send($1) == args.first } if name.to_s =~ /^find_by_(.+)$/
        super
      end
    end

    def to_model
      self
    end

    def valid?
      true
    end

    def destroyed?
      @destroyed ||= false
    end

    def new_record?
      transient?
    end

    def save
      persist
    end

    alias save! save

    def destroy
      @destroyed = true
      desist
    end

    def tap
      yield(self)
      self
    end

    def errors
      @errors ||= begin
        errors = Hash.new { |h,k| h[k] = [] }
        def errors.full_messages
          values.flatten
        end
        errors
      end
    end

    def self.included(klass)
      klass.send :include, Persistable
      klass.extend ClassMethods
      super
    end
  end
end
