# frozen_string_literal: true

require 'test_helper'

class ActiveRecordMigratorPatchTest < ActiveSupport::TestCase
  describe 'any_migrations?' do
    it 'must return true' do
      _(ActiveRecord::Migrator.any_migrations?).must_equal true
    end
  end
end
