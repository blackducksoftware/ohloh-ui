# frozen_string_literal: true

require 'test_helper'

class AffiliationValidationTest < ActiveSupport::TestCase
  it 'must match affiliation_type against allowed types' do
    account = build(:account)
    account.affiliation_type = 'invalid'
    account.valid?

    account.errors.messages[:affiliation_type].first.must_equal I18n.t(:is_invalid)
  end

  it 'must not allow blank organization_name when affiliation_type is other' do
    account = build(:account)
    account.affiliation_type = 'other'
    account.organization_name = nil
    account.valid?

    account.errors.messages[:organization_name].first.must_equal I18n.t(:cant_be_blank)
  end

  it 'must allow blank organization_name when affiliation_type is not other' do
    account = build(:account)
    account.affiliation_type = :unaffiliated
    account.organization_name = nil
    account.valid?

    account.errors.messages.must_be_empty
  end

  it 'must not allow blank organization_id when affiliation_type is specified' do
    account = build(:account)
    account.affiliation_type = 'specified'
    account.organization_id = ''
    account.valid?

    account.errors.messages[:organization_id].first.must_equal I18n.t(:cant_be_blank)
  end

  it 'must allow blank organization_id when affiliation_type is not specified' do
    account = build(:account)
    account.affiliation_type = :other
    account.organization_id = nil
    account.organization_name = :something
    account.valid?

    account.errors.messages.must_be_empty
  end
end
