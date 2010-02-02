#!/usr/bin/env maglev-ruby -rubygems
require File.expand_path("../../test_helper", __FILE__)
require "persistable/active_model"

module Persistable
  class ActiveModelTest < Test::Unit::TestCase

    class ::Railsy
      include Persistable::ActiveModel
      attr_accessor :name, :value
      alias to_param name
    end

    def setup
      @foo = Railsy.new :name => "foo", :value => 42
      @bar = Railsy.new :name => "bar", :value => 23
      @lousy_examples = [@foo, @bar]
    end

    def save_all
      @lousy_examples.each { |e| e.save }
    end

    def teardown
      Railsy.delete_all
    end

    def test_class_store_starts_empty
      assert Railsy.all.empty?
    end

    def test_class_new_records_are_flagged
      assert @foo.new_record?
      @foo.save
      assert !@foo.new_record?
    end

    def test_passed_hash_args_become_method_calles
      some_class = Class.new do
        include Persistable::ActiveModel
        attr_reader :foo
        def bar=(value)
          @foo = value + 10
        end
      end
      assert_equal some_class.new(:bar => 10).foo, 20
    end

    def test_create_stores_objects_directly
      blah = Railsy.create :name => "blah"
      assert !blah.new_record?
      assert_equal Railsy.find("blah"), blah
    end

    def test_stored_instances_can_be_found_by_param
      save_all
      assert_equal Railsy.find("foo"), @foo
      assert_equal Railsy.find("bar"), @bar
    end

    def test_stored_instances_can_be_found_by_field
      save_all
      assert_equal Railsy.find_by_name("foo"), @foo
      assert_equal Railsy.find_by_value(42),   @foo
      assert_equal Railsy.find_by_name("bar"), @bar
      assert_equal Railsy.find_by_value(23),   @bar
    end
    
    def test_destroy_removes_objects
      save_all
      assert_equal Railsy.find_by_name("foo"), @foo
      @foo.destroy
      assert_equal Railsy.find_by_name("foo"), nil
    end

  end
end