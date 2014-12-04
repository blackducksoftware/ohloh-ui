require 'test_helper'

class DomainBlacklistTest < ActiveSupport::TestCase
  test 'responds to contains?' do
    assert DomainBlacklist.respond_to?(:contains?)
  end

  test 'contains? returns false if it does not contain a domain' do
    assert_equal false, DomainBlacklist.contains?('non_existent_domain.com')
  end

  test 'contains? returns true if it contains a domain' do
    DomainBlacklist.create(domain: 'test_domain.com')
    assert_equal true, DomainBlacklist.contains?('test_domain.com')
  end

  test 'contains? returns false if it contains different domain' do
    DomainBlacklist.create(domain: 'first_domain.com')
    assert_equal false, DomainBlacklist.contains?('second_domain.com')
  end

  test 'record creations is case insensitive' do
    DomainBlacklist.create(domain: 'first_domain.com')
    assert_raise ActiveRecord::RecordInvalid do
      DomainBlacklist.create!(domain: 'First_Domain.com')
    end
  end

  test 'contains? returns true for case insensitive match' do
    DomainBlacklist.create(domain: 'case_insensitive.com')
    assert_equal true, DomainBlacklist.contains?('Case_Insensitive.com')
  end

  test 'email_banned? returns false for non-matching domain' do
    assert_equal false, DomainBlacklist.email_banned?('bob@new_domain.com')
  end

  test 'email_banned? returns true for same domain' do
    DomainBlacklist.create(domain: 'banned.com')
    assert_equal true, DomainBlacklist.email_banned?('bad@banned.com')
  end

  test 'email_banned? returns true for case different domain' do
    DomainBlacklist.create(domain: 'banned.com')
    assert_equal true, DomainBlacklist.email_banned?('CAPS@BANNED.COM')
  end
end
