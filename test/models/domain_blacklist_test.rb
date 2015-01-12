require 'test_helper'

class DomainBlacklistTest < ActiveSupport::TestCase
  it 'responds to contains?' do
    DomainBlacklist.must_respond_to(:contains?)
  end

  it 'contains? returns false if it does not contain a domain' do
    DomainBlacklist.contains?('non_existent_domain.com').must_equal false
  end

  it 'contains? returns true if it contains a domain' do
    DomainBlacklist.create(domain: 'test_domain.com')
    DomainBlacklist.contains?('test_domain.com').must_equal true
  end

  it 'contains? returns false if it contains different domain' do
    DomainBlacklist.create(domain: 'first_domain.com')
    DomainBlacklist.contains?('second_domain.com').must_equal false
  end

  it 'record creations is case insensitive' do
    DomainBlacklist.create(domain: 'first_domain.com')
    -> { DomainBlacklist.create!(domain: 'First_Domain.com') }
      .must_raise(ActiveRecord::RecordInvalid)
  end

  it 'contains? returns true for case insensitive match' do
    DomainBlacklist.create(domain: 'case_insensitive.com')
    DomainBlacklist.contains?('Case_Insensitive.com').must_equal true
  end

  it 'email_banned? returns false for non-matching domain' do
    DomainBlacklist.email_banned?('bob@new_domain.com').must_equal false
  end

  it 'email_banned? returns true for same domain' do
    DomainBlacklist.create(domain: 'banned.com')
    DomainBlacklist.email_banned?('bad@banned.com').must_equal true
  end

  it 'email_banned? returns true for case different domain' do
    DomainBlacklist.create(domain: 'banned.com')
    DomainBlacklist.email_banned?('CAPS@BANNED.COM').must_equal true
  end
end
