# frozen_string_literal: true

require 'test_helper'

class AccountFindTest < ActiveSupport::TestCase
  describe 'by_id_or_login' do
    let(:account) { create(:account) }

    it 'must find account by id' do
      found_account = AccountFind.by_id_or_login(account.id.to_s)
      _(found_account).must_equal account
    end

    it 'must find account by login' do
      found_account = AccountFind.by_id_or_login(account.login)
      _(found_account).must_equal account
    end

    it 'must find account case insensitive' do
      found_account = AccountFind.by_id_or_login(account.login.upcase)
      _(found_account).must_equal account
    end

    it 'must return nil for non existent value' do
      found_account = AccountFind.by_id_or_login('non_existent_login')
      _(found_account).must_be_nil
    end
  end
end
