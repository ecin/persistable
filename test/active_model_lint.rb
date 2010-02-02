# Copyright (c) 2004-2010 David Heinemeier Hansson
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# You can test whether an object is compliant with the ActiveModel API by
# including ActiveModel::Lint::Tests in your TestCase. It will included
# tests that tell you whether your object is fully compliant, or if not,
# which aspects of the API are not implemented.
#
# These tests do not attempt to determine the semantic correctness of the
# returned values. For instance, you could implement valid? to always
# return true, and the tests would pass. It is up to you to ensure that
# the values are semantically meaningful.
#
# Objects you pass in are expected to return a compliant object from a
# call to to_model. It is perfectly fine for to_model to return self.
module ActiveModel
  module Lint
    module Tests
      # == Responds to <tt>valid?</tt>
      #
      # Returns a boolean that specifies whether the object is in a valid or invalid
      # state.
      def test_valid?
        assert model.respond_to?(:valid?), "The model should respond to valid?"
        assert_boolean model.valid?, "valid?"
      end

      # == Responds to <tt>new_record?</tt>
      #
      # Returns a boolean that specifies whether the object has been persisted yet.
      # This is used when calculating the URL for an object. If the object is
      # not persisted, a form for that object, for instance, will be POSTed to the
      # collection. If it is persisted, a form for the object will put PUTed to the
      # URL for the object.
      def test_new_record?
        assert model.respond_to?(:new_record?), "The model should respond to new_record?"
        assert_boolean model.new_record?, "new_record?"
      end

      def test_destroyed?
        assert model.respond_to?(:destroyed?), "The model should respond to destroyed?"
        assert_boolean model.destroyed?, "destroyed?"
      end

      # == Naming
      #
      # Model.model_name must returns a string with some convenience methods as
      # :human and :partial_path. Check ActiveModel::Naming for more information.
      #
      def test_model_naming
        assert model.class.respond_to?(:model_name), "The model should respond to model_name"
        model_name = model.class.model_name
        assert_kind_of String, model_name
        assert_kind_of String, model_name.human
        assert_kind_of String, model_name.partial_path
        assert_kind_of String, model_name.singular
        assert_kind_of String, model_name.plural
      end

      # == Errors Testing
      # 
      # Returns an object that has :[] and :full_messages defined on it. See below
      # for more details.
      #
      # Returns an Array of Strings that are the errors for the attribute in
      # question. If localization is used, the Strings should be localized
      # for the current locale. If no error is present, this method should
      # return an empty Array.
      def test_errors_aref
        assert model.respond_to?(:errors), "The model should respond to errors"
        assert model.errors[:hello].is_a?(Array), "errors#[] should return an Array"
      end

      # Returns an Array of all error messages for the object. Each message
      # should contain information about the field, if applicable.
      def test_errors_full_messages
        assert model.respond_to?(:errors), "The model should respond to errors"
        assert model.errors.full_messages.is_a?(Array), "errors#full_messages should return an Array"
      end

      private
        def model
          assert @model.respond_to?(:to_model), "The object should respond_to to_model"
          @model.to_model
        end

        def assert_boolean(result, name)
          assert result == true || result == false, "#{name} should be a boolean"
        end
    end
  end
end
