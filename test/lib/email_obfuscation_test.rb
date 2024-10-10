# frozen_string_literal: true

require 'test_helper'

class EmailObfuscationTest < ActiveSupport::TestCase
  describe 'obfuscate_email' do
    it 'must mask email address' do
      email = Faker::Internet.email

      _(Commit.new.obfuscate_email(email)).wont_equal email
    end
  end
end
