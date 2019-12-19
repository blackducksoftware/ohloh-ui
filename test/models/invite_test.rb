# frozen_string_literal: true

require 'test_helper'
require_relative '../../app/models/concerns/on_behalf'

module OnBehalf
  remove_const :MAX_SENT
  MAX_SENT = 5 # changing from 50 to 3 for testing purpose
end

class InviteTest < ActiveSupport::TestCase
  before { create_must_and_wont_aliases(Invite) }
  let(:invite) { build(:invite) }

  it 'should be valid' do
    invite.must_be :valid?
  end

  it 'contribution should be valid' do
    invite.contribution = nil
    invite.wont_be :valid?
    invite.errors.must_include(:contribution)
  end

  it 'must throw error on invitee email when blank and invalid' do
    invite.invitee_email = nil
    invite.wont_be :valid?
    invite.errors.must_include(:invitee_email)

    invite.invitee_email = 'invalid_email_without_at_symbol'
    invite.wont_be :valid?
    invite.errors.must_include(:invitee_email)

    invite.invitee_email = Faker::Internet.free_email(100) # long email
    invite.wont_be :valid?
    invite.errors.must_include(:invitee_email)

    invite.invitee_email = 'a@a' # short email
    invite.wont_be :valid?
    invite.errors.must_include(:invitee_email)
  end

  it 'should create the invite and have the flash message' do
    invite.must :save
    invite.success_flash.must_match 'Thank you for inviting'
    invite.activation_code.wont_be :nil?
  end

  it 'should not send a duplicate invite' do
    hash = { invitor: Account.last, invitee_email: 'test@domain.com' }
    first_invite = create(:invite,  hash)
    second_invite = build(:invite,  hash)
    second_invite.contribution = first_invite.contribution
    second_invite.wont :save
    second_invite.wont_be :valid?
    second_invite.errors.must_include(:invitee_email)
    second_invite.errors.messages[:invitee_email].first.must_equal I18n.t('invites.invited_to_claim')
  end

  it 'should not send invite for an existing account' do
    accounts = Account.limit(1).order('RANDOM()')
    hash = { invitor: accounts.first, invitee_email: accounts.last.email }
    invite = build(:invite, hash)
    invite.wont :save
    invite.wont_be :valid?
    invite.errors.must_include(:invitee_email)
    invite.errors.messages[:invitee_email].last.must_equal I18n.t('invites.invited_to_join')
  end

  it 'invitor should not send beyond 5 invites' do
    invitor = create(:account)
    FactoryBot.create_list(:invite, 5, invitor: invitor)

    error_invite = build(:invite, invitor: invitor)
    error_invite.wont :save
    error_invite.errors.must_include(:send_limit)
    error_invite.errors[:send_limit].first.must_match 'You\'ve already sent the maximum number of invites'
  end

  it 'invitee should not receive beyond 5 invites' do
    FactoryBot.create_list(:invite, 5, invitee_email: 'max_received@domain.com')
    error_invite = build(:invite, invitee_email: 'max_received@domain.com')
    error_invite.wont :save
    error_invite.errors.must_include(:send_limit)
    error_invite.errors[:send_limit].first.must_match 'Open Hub has already sent the maximum number of invites'
  end
end
