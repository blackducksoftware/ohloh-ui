# frozen_string_literal: true

require 'test_helper'

class ProjectExistsErrorTest < ActiveSupport::TestCase
  describe 'ProjectExistsError' do
    it 'should be a StandardError' do
      _(ProjectExistsError.ancestors).must_include StandardError
    end

    it 'should be raisable with a message' do
      error_message = 'Project already exists'

      exception = assert_raises ProjectExistsError do
        raise ProjectExistsError, error_message
      end

      _(exception.message).must_equal error_message
    end

    it 'should be raisable without a message' do
      exception = assert_raises ProjectExistsError do
        raise ProjectExistsError
      end

      _(exception).must_be_instance_of ProjectExistsError
    end

    it 'should inherit StandardError behavior' do
      error = ProjectExistsError.new('test message')
      _(error.message).must_equal 'test message'
      _(error.class.name).must_equal 'ProjectExistsError'
    end
  end
end
