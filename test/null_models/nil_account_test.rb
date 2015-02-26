require 'test_helper'

class NilAccountTest < ActiveSupport::TestCase
  let(:nil_account) { NilAccount.new }

  describe 'id' do
    it 'should return nil' do
      nil_account.id.must_equal nil
    end
  end

  describe 'level' do
    it 'should return nil' do
      nil_account.level.must_equal nil
    end
  end

  describe 'admin?' do
    it 'should return nil' do
      nil_account.admin?.must_equal false
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
end
