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
    _(invite).must_be :valid?
  end

  it 'contribution should be valid' do
    invite.contribution = nil
    _(invite).wont_be :valid?
    _(invite.errors).must_include(:contribution)
  end

  it 'must throw error on invitee email when blank and invalid' do
    invite.invitee_email = nil
    _(invite).wont_be :valid?
    _(invite.errors).must_include(:invitee_email)

    invite.invitee_email = 'invalid_email_without_at_symbol'
    _(invite).wont_be :valid?
    _(invite.errors).must_include(:invitee_email)

    invite.invitee_email = Faker::Internet.email(name: 100) # long email
    _(invite).wont_be :valid?
    _(invite.errors).must_include(:invitee_email)

    invite.invitee_email = 'a@a' # short email
    _(invite).wont_be :valid?
    _(invite.errors).must_include(:invitee_email)
  end

  it 'should create the invite and have the flash message' do
    _(invite).must_be :save
    _(invite.success_flash).must_match 'Thank you for inviting'
    _(invite.activation_code).wont_be :nil?
  end

  it 'should not send a duplicate invite' do
    hash = { invitor: Account.last, invitee_email: 'test@domain.com' }
    first_invite = create(:invite,  hash)
    second_invite = build(:invite,  hash)
    second_invite.contribution = first_invite.contribution
    _(second_invite).wont_be :save
    _(second_invite).wont_be :valid?
    _(second_invite.errors).must_include(:invitee_email)
    _(second_invite.errors.messages[:invitee_email].first).must_equal I18n.t('invites.invited_to_claim')
  end

  it 'should not send invite for an existing account' do
    accounts = Account.limit(1).order(Arel.sql('RANDOM()'))
    hash = { invitor: accounts.first, invitee_email: accounts.last.email }
    invite = build(:invite, hash)
    _(invite).wont_be :save
    _(invite).wont_be :valid?
    _(invite.errors).must_include(:invitee_email)
    _(invite.errors.messages[:invitee_email].last).must_equal I18n.t('invites.invited_to_join')
  end

  it 'invitor should not send beyond 5 invites' do
    invitor = create(:account)
    FactoryBot.create_list(:invite, 5, invitor: invitor)

    error_invite = build(:invite, invitor: invitor)
    _(error_invite).wont_be :save
    _(error_invite.errors).must_include(:send_limit)
    _(error_invite.errors[:send_limit].first).must_match 'You\'ve already sent the maximum number of invites'
  end

  it 'invitee should not receive beyond 5 invites' do
    FactoryBot.create_list(:invite, 5, invitee_email: 'max_received@domain.com')
    error_invite = build(:invite, invitee_email: 'max_received@domain.com')
    _(error_invite).wont_be :save
    _(error_invite.errors).must_include(:send_limit)
    _(error_invite.errors[:send_limit].first).must_match 'Open Hub has already sent the maximum number of invites'
  end
end
