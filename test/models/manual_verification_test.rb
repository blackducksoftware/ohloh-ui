# frozen_string_literal: true

require 'test_helper'

class ManualVerificationTest < ActiveSupport::TestCase
  it 'must allow duplicate manual verification records' do
    account = create(:account)
    verification = create(:manual_verification, account: account)
    new_verification = build(:manual_verification, account: account, unique_id: verification.unique_id)

    _(new_verification).must_be :valid?
  end
end
