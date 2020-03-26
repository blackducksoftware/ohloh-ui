# frozen_string_literal: true

require 'test_helper'

class SchemaStatementsTest < ActiveSupport::TestCase
  describe 'dump_schema_information' do
    it 'should dump the schema migrations details' do
      ActiveRecord::Base.connection.dump_schema_information.wont_be_nil
    end
  end
end
