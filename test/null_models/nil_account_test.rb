# frozen_string_literal: true

require 'test_helper'

class NilAccountTest < ActiveSupport::TestCase
  let(:nil_account) { NilAccount.new }

  describe 'id' do
    it 'should return nil' do
      assert_nil nil_account.id
    end
  end

  describe 'level' do
    it 'should return nil' do
      assert_nil nil_account.level
    end
  end

  describe 'actions' do
    it 'should return []' do
      nil_account.actions.must_equal []
    end
  end

  describe 'nil?' do
    it 'should return true' do
      nil_account.nil?.must_equal true
    end
  end

  describe 'blank?' do
    it 'should return true' do
      nil_account.blank?.must_equal true
    end
  end

  describe 'access' do
    it 'must return access object for self' do
      nil_account.access.class.must_equal Account::Access
    end
  end
end
