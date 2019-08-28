# frozen_string_literal: true

require 'test_helper'

class AnonymousAccountTest < ActiveSupport::TestCase
  describe 'create' do
    it 'must not send emails' do
      assert_no_difference -> { ActionMailer::Base.deliveries.count } do
        AnonymousAccount.create!
      end
    end
  end
end
