# frozen_string_literal: true

require 'test_helper'

class GithubVerificationTest < ActiveSupport::TestCase
  it 'wont allow reusing verification from spam account' do
    account = create(:account)
    account.access.spam!

    verification = build(:github_verification, unique_id: account.github_verification.unique_id)
    new_account = build(:account, github_verification: verification)

    new_account.wont_be :valid?
    new_account.errors.messages[:'github_verification.unique_id'].must_be :present?
  end

  it 'must raise appropriate error for uniqueness' do
    verification = create(:github_verification)
    new_verification = build(:github_verification, unique_id: verification.unique_id)

    new_verification.wont_be :valid?
    message = I18n.t('activerecord.errors.models.github_verification.attributes.unique_id.taken')
    new_verification.errors.messages[:unique_id].first.must_equal message
  end
end
