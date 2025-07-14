# frozen_string_literal: true

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  let(:account) { create(:account) }
  let(:admin) { create(:admin) }

  it 'must create account without email and password confirmation' do
    assert_difference('Account.count', 1) do
      create(:account)
    end
  end

  it '#sent_kudos' do
    Kudo.delete_all
    create(:kudo, sender: admin, account: create(:account, name: 'joe'))
    create(:kudo, sender: admin, account: create(:account, name: 'moe'))

    _(admin.sent_kudos.count).must_equal 2
  end

  it '#claimed_positions' do
    proj = create(:project)
    create_position(account: account, project: proj)
    _(account.positions.count).must_equal 1
    _(account.claimed_positions.count).must_equal 1
  end

  it 'the account model should be valid' do
    account = build(:account)
    _(account).must_be :valid?
  end

  it 'should validate email' do
    account = build(:account)
    account.email = 'ab'
    _(account).wont_be :valid?
    _(account.errors).must_include(:email)
    expected_error_message = ['is too short (minimum is 3 characters)', I18n.t('accounts.invalid_email_address')]
    _(account.errors.messages[:email]).must_equal expected_error_message
  end

  it 'should validate that email is unique' do
    create(:account, email: 'unique1@gmail.com')
    bad_account_one = build(:account, email: 'unique1@gmail.com')
    bad_account_two = build(:account, email: 'UNIQUE1@gmail.com')
    unique_account = build(:account, email: 'unique2@gmail.com')

    _(bad_account_one).wont_be :valid?
    _(bad_account_two).wont_be :valid?

    expected_error_message = [I18n.t('activerecord.errors.models.account.attributes.email.unique')]

    _(bad_account_one.errors).must_include(:email)
    _(bad_account_one.errors.messages[:email]).must_equal expected_error_message

    _(bad_account_two.errors).must_include(:email)
    _(bad_account_two.errors.messages[:email]).must_equal expected_error_message

    _(unique_account).must_be :valid?
  end

  it 'must ensure name values have safe sql patterns' do
    bad_account_one = build(:account, name: 'foo--bar')
    bad_account_two = build(:account, name: 'foo=bar')
    bad_account_three = build(:account, name: 'foobar;')
    bad_account_four = build(:account, name: 'http://foobar')

    _(bad_account_one).wont_be :valid?
    _(bad_account_two).wont_be :valid?
    _(bad_account_three).wont_be :valid?
    _(bad_account_four).wont_be :valid?
  end

  it 'should validate URL format when value is available' do
    account = build(:account)
    _(account).must_be :valid?

    account = build(:account, url: '')
    _(account).must_be :valid?

    account = build(:account, url: 'openhub.net')
    _(account).wont_be :valid?
    _(account.errors).must_include(:url)
    _(account.errors.messages[:url].first).must_equal I18n.t('accounts.invalid_url_format')
  end

  it 'should validate that login is unique' do
    create(:account, login: 'warmachine')
    bad_account_one = build(:account, login: 'warmachine')
    bad_account_two = build(:account, login: 'WARMACHINE')

    _(bad_account_one).wont_be :valid?
    _(bad_account_two).wont_be :valid?

    expected_error_message = [I18n.t('activerecord.errors.models.account.attributes.login.unique')]

    _(bad_account_one.errors).must_include(:login)
    _(bad_account_one.errors.messages[:login]).must_equal expected_error_message

    _(bad_account_two.errors).must_include(:login)
    _(bad_account_two.errors.messages[:login]).must_equal expected_error_message
  end

  it 'should validate login' do
    account = build(:account)
    _(account).must_be :valid?

    account = build(:account, login: '')
    _(account).wont_be :valid?
    expected_error_message =
      ['can\'t be blank', 'is too short (minimum is 3 characters)']
    _(account.errors.messages[:login]).must_equal expected_error_message

    create(:account, login: 'openhub_dev')
    account = build(:account, login: 'openhub_dev')
    _(account).wont_be :valid?
    _(account.errors).must_include(:login)
    _(account.errors.messages[:login]).must_equal ['has already been taken']
  end

  it 'should validate password' do
    account = build(:account)
    _(account).must_be :valid?

    account = build(:account, password: '')
    _(account).wont_be :valid?
    _(account.errors).must_include(:password)
    _(account.errors.messages[:password]).must_include 'Please provide a password.'
  end

  it 'must update new password by passing previous password' do
    account = create(:account, password: 'barfoo')

    account.validate_current_password = true
    account.current_password = 'barfoo'
    account.password = 'foobar'

    _(account).must_be :valid?
  end

  it 'should validate twitter account only if its present' do
    account = build(:account)
    _(account).must_be :valid?

    account = build(:account, twitter_account: '')
    _(account).must_be :valid?

    account = build(:account, twitter_account: 'abcdefghijklmnopqrstuvwxyz')
    _(account).wont_be :valid?
    _(account.errors).must_include(:twitter_account)
    _(account.errors.messages[:twitter_account]).must_equal ['is too long (maximum is 15 characters)']
  end

  it 'should validate user full name' do
    account = build(:account)
    _(account).must_be :valid?

    account = build(:account, name: '')
    _(account).must_be :valid?

    account = build(:account, name: Faker::Name.name * 8)
    _(account).wont_be :valid?
    _(account.errors).must_include(:name)
    _(account.errors.messages[:name]).must_equal ['is too long (maximum is 50 characters)']
  end

  it 'should send an email if url is changed' do
    ActionMailer::Base.deliveries.clear
    account = create(:account)
    account.update(url: Faker::Internet.url)
    email = ActionMailer::Base.deliveries.last
    _(email.subject).must_equal 'OpenHub: review account data for SPAM'
  end

  it 'should update the markup(about me) when updating a record' do
    account = create(:account)
    about_me = Faker::Lorem.paragraph(sentence_count: 2)
    account.about_raw = about_me
    account.save
    _(account.markup.raw).must_equal about_me
  end

  it 'should not update the markup(about me) when exceeding the limit' do
    about_me = Faker::Lorem.paragraph(sentence_count: 130)
    account.about_raw = about_me
    _(account).wont_be :valid?
    _(account.markup.errors).must_include(:raw)
  end

  it 'should send an email if markup has a link' do
    ActionMailer::Base.deliveries.clear
    account = create(:account)
    about_me = Faker::Internet.url
    account.about_raw = about_me
    account.save
    email = ActionMailer::Base.deliveries.last
    _(email.subject).must_equal 'OpenHub: review account data for SPAM'
  end

  it 'should error out when affiliation_type is not specified' do
    account.affiliation_type = ''
    _(account).wont_be :valid?
    _(account.errors).must_include(:affiliation_type)
    _(account.errors.messages[:affiliation_type].first).must_equal I18n.t(:is_invalid)
  end

  it 'should search by login and sort by position and char length' do
    create(:account, login: 'test')
    create(:account, login: 'account_test', email: 'test2@openhub.net')
    create(:account, login: 'tester', email: 'test3@openhub.net')
    create(:account, login: 'unittest', email: 'test4@openhub.net')
    create(:account, login: 'unittest1', email: 'test5@openhub.net')
    account_search = Account.simple_search('test')
    _(account_search.size).must_equal 5
    _(account_search.first.login).must_equal 'test'
    _(account_search.second.login).must_equal 'tester'
    _(account_search.third.login).must_equal 'unittest'
    _(account_search.fourth.login).must_equal 'unittest1'
    _(account_search.fifth.login).must_equal 'account_test'
  end

  it 'must protect from malicious sql' do
    create(:account, login: 'account-test')
    account_search = Account.simple_search("' OR 1 = 1")
    _(account_search.first).must_be_nil
  end

  it 'should return recently active accounts' do
    best_account_analysis = create(:best_account_analysis)
    best_account_analysis.account
                         .update(best_vita_id: best_account_analysis.id, created_at: 4.days.ago)
    account_analysis_fact = best_account_analysis.account_analysis_fact
    account_analysis_fact.update(last_checkin: Time.current)

    recently_active = Account.recently_active
    _(recently_active).wont_be_nil
    _(recently_active.count).must_equal 1
  end

  it 'should not return non recently active accounts' do
    recently_active = Account.recently_active
    _(recently_active).must_be_empty
    _(recently_active.count).must_equal 0
  end

  it 'should not include BOT accounts in active accounts' do
    best_account_analysis = create(:best_account_analysis)
    level = Account::Access::BOT
    best_account_analysis.account.update(best_vita_id: best_account_analysis.id,
                                         created_at: 4.days.ago, level: level)
    account_analysis_fact = best_account_analysis.account_analysis_fact
    account_analysis_fact.update(last_checkin: Time.current)
    _(Account.recently_active.count).must_equal 0
  end

  it 'it should error out when affiliation_type is specified and org name is blank' do
    account.affiliation_type = 'specified'
    account.organization_id = ''
    _(account).wont_be :valid?
    _(account.errors).must_include(:organization_id)
    _(account.errors.messages[:organization_id].first).must_equal I18n.t(:cant_be_blank)
  end

  it 'facts_joins should accounts with positions projects and name_facts' do
    project = create(:project)
    name = create(:name)
    name_fact = create(:name_fact, analysis: project.best_analysis, name: name, vita_id: create(:account_analysis).id)
    name_fact.account_analysis.account.update(best_vita_id: name_fact.vita_id, latitude: 30.26, longitude: -97.74)
    create(:position, project: project, name: name, account: name_fact.account_analysis.account)

    accounts_with_facts = Account.with_facts
    _(accounts_with_facts.size).must_equal 1
    _(accounts_with_facts.first).must_equal name_fact.account_analysis.account
  end

  it 'should validate current password error message' do
    account.update(password: 'newpassword', current_password: 'dummy password', validate_current_password: true)
    _(account.errors.size).must_equal 1
    error_message = [I18n.t('activerecord.errors.models.account.attributes.current_password.invalid')]
    _(error_message).must_equal account.errors[:current_password]
  end

  it 'should update password with valid passwords' do
    account = create(:account, password: 'testing')
    account.update(password: 'newpassword', current_password: 'testing')
    _(account.reload.encrypted_password).must_equal account.encrypt('newpassword', account.salt)
  end

  it 'should not update password if current_password is an empty string' do
    account.update(password: 'newpassword', current_password: '', validate_current_password: true)
    assert_not_equal account.reload.encrypted_password, account.encrypt('newpassword', account.salt)
  end

  it 'should not update if password is blank' do
    account = create(:account, password: 'testing')
    account.update(password: '', current_password: 'testing')
    assert account.invalid?
  end

  it 'should not update password if password is less than 5 characters' do
    account = create(:account, password: 'testing')
    account.update(password: 'pass', current_password: 'testing')
    assert account.invalid?
  end

  describe 'first commit date' do
    it 'it should get the first checkin for a account position' do
      account_analysis = create(:best_account_analysis, account_id: account.id)
      account.update_column(:best_vita_id, account_analysis.id)
      _(account.first_commit_date).must_equal account_analysis.account_analysis_fact
                                                              .first_checkin.to_date.beginning_of_month
    end

    it 'it should return nil when account has no best_account_analysis' do
      _(admin.first_commit_date).must_be_nil
    end
  end

  describe 'login validations' do
    it 'test should require login' do
      assert_no_difference 'Account.count' do
        account = build(:account, login: nil)
        account.valid?
        _(account.errors.messages[:login]).must_be :present?
      end
    end

    it 'test valid logins' do
      account = build(:account)
      logins = %w[rockola ROCKOLA Rockola Rock_Ola F323 Géré-my]

      logins.each do |login|
        account.login = login
        _(account).must_be :valid?
      end
    end

    it 'test login not urlable' do
      account = build(:account)
      bad_logins = %w(123 user.allen $foo] _user -user)

      bad_logins.each do |bad_login|
        account.login = bad_login
        _(account).wont_be :valid?
      end
    end

    it 'test bad login on create' do
      account = build(:account, login: '$foo')
      account.valid?
      _(account.errors.messages[:login]).must_be :present?
    end

    it 'test login on update' do
      # fake a bad login already in the db
      account = create(:account)
      account.login = '$bad_login$'
      _(account.save(validate: false)).wont_equal false

      # ok, now update something else than login
      account.reload
      account.name = 'My New Name'
      _(account.save).wont_equal false

      # ok, now try updating the name to something new, yet still wrong
      account.reload
      account.login = '$another_bad_login$'
      _(account.save).must_equal false
      _(account.errors.messages[:login]).must_be :present?
    end
  end

  describe 'most_experienced_language' do
    it 'must return the language having a account_analysis_language_fact' do
      create(:language, category: 0)
      lang2 = create(:language, category: 2)
      account_analysis = create(:account_analysis)
      account_analysis.account.update!(best_vita_id: account_analysis.id)
      create(:account_analysis_language_fact, language: lang2, account_analysis: account_analysis)

      _(lang2.nice_name).must_equal account_analysis.account.most_experienced_language.nice_name
    end

    it 'must return the language with lowest category' do
      lang1 = create(:language, category: 0)
      lang2 = create(:language, category: 2)
      account_analysis = create(:account_analysis)
      account_analysis.account.update!(best_vita_id: account_analysis.id)
      create(:account_analysis_language_fact, language: lang1, total_commits: 0, account_analysis: account_analysis)
      create(:account_analysis_language_fact, language: lang2, total_commits: 300, account_analysis: account_analysis,
                                              total_activity_lines: 200, total_months: 30)

      _(lang1.nice_name).must_equal account_analysis.account.most_experienced_language.nice_name
    end
  end

  describe 'to_param' do
    it 'must return login when it is urlable' do
      account = build(:account, login: 'stan')
      _(account.to_param).must_equal account.login
    end

    it 'must return id when login is not urlable' do
      account = create(:account)
      account.login = '$one'
      _(account.to_param).must_equal account.id.to_s
    end
  end

  it '#email_topics' do
    _(admin.email_topics?).must_equal true
    admin.email_master = true
    admin.email_posts = false
    _(admin.email_topics?).must_equal false
    admin.email_master = true
    admin.email_posts = true
    _(admin.email_topics?).must_equal true
    admin.email_master = false
    admin.email_posts = true
    _(admin.email_topics?).must_equal false
  end

  it '#email_kudos' do
    _(admin.email_kudos?).must_equal true
    admin.email_master = true
    admin.email_kudos = false
    _(admin.email_kudos?).must_equal false
    admin.email_master = true
    admin.email_kudos = true
    _(admin.email_kudos?).must_equal true
    admin.email_master = false
    admin.email_kudos = true
    _(admin.email_kudos?).must_equal false
  end

  it '#update_akas' do
    project = create(:project)
    account = create(:account)
    project.update!(best_analysis_id: create(:analysis).id, editor_account: account)
    position = create_position(project: project, account: account)
    account.update_akas
    _(account.akas.split("\n").sort).must_equal [position.name.name].sort
  end

  it '#links' do
    project = create(:project)
    project.editor_account = account
    link = project.links.new(
      url: 'http://www.google.com',
      title: 'title',
      link_category_id: Link::CATEGORIES[:Other]
    )
    link.editor_account = account
    link.save!
    _(account.links).must_include(link)
  end

  it 'badges list' do
    account = create(:account)
    badges = %w[badge1 badge2]
    Badge.expects(:all_eligible).with(account).returns(badges)
    _(account.badges).must_equal badges
  end

  it '#non_human_ids' do
    create(:account, login: 'uber_data_crawler')
    ohloh_slave_id = Account.hamster.id
    uber_data_crawler_id = Account.uber_data_crawler.id

    _(Account.non_human_ids.size).must_equal 2
    _(Account.non_human_ids).must_include(ohloh_slave_id)
    _(Account.non_human_ids).must_include(uber_data_crawler_id)
  end

  describe 'validations' do
    it 'should require password' do
      assert_no_difference 'Account.count' do
        user = build(:account, password: nil)
        user.valid?
        _(user.errors.messages[:password]).must_be :present?
      end
    end

    it 'email shouldn\'t be blank' do
      assert_no_difference 'Account.count' do
        user = build(:account, email: '')
        user.valid?
        _(user.errors.messages[:email]).must_be :present?
        _(user.errors.messages[:email].last).must_equal I18n.t('accounts.invalid_email_address')
      end
    end

    it 'must validate format of organization_name' do
      account = build(:account)
      account.affiliation_type = 'other'
      account.organization_name = '_org'
      account.valid?

      message = I18n.t('activerecord.errors.models.account.attributes.organization_name.invalid')
      _(account.errors.messages[:organization_name].first).must_equal message
    end

    it 'must validated length of organization_name' do
      account = build(:account)
      account.affiliation_type = 'other'
      account.organization_name = 'A1'
      account.valid?

      message = 'is too short (minimum is 3 characters)'
      _(account.errors.messages[:organization_name].first).must_equal message
    end

    it 'must allow blank organization_name' do
      account = build(:account)
      account.affiliation_type = 'specified'
      account.organization_name = ''
      account.valid?

      _(account.errors.messages[:organization_name]).must_be :empty?
    end
  end

  it 'disallow html tags in url' do
    account = create(:account, url: 'http://www.ohloh.net/')
    _(account).must_be :valid?

    account.url = %q(http://1.cc/ <img src="s" onerror="top.location=' http://vip-feed.com/35898/buy+adderall.html';">)
    _(account).wont_be :valid?
    _(account.errors.messages[:url]).must_be :present?
  end

  it 'allow latin url in account url' do
    account = create(:account, url: 'https://mickaël.bucas.name/')
    _(account).must_be :valid?
  end

  it 'must create an organization job when account is deleted' do
    account = create(:account)
    organization = create(:organization)
    account.update_attribute(:organization_id, organization.id)

    Job.delete_all
    account.destroy

    _(OrganizationAnalysisJob.count).must_equal 1
    _(OrganizationAnalysisJob.first.organization_id).must_equal organization.id
  end

  it 'must create 2 organization jobs for a change in organization_id' do
    organization = create(:organization)
    account = create(:account, organization_id: organization.id)

    Job.delete_all
    account.update!(organization_id: create(:organization).id)

    _(OrganizationAnalysisJob.count).must_equal 2
  end

  describe 'kudo_rank' do
    it 'should return 1 if kudo_rank is nil' do
      admin.person.update_column(:kudo_rank, nil)
      _(admin.kudo_rank).must_equal 1
    end

    it 'should return kudo_rank' do
      account = create(:account)
      account.person.update_column(:kudo_rank, 10)
      _(account.kudo_rank).must_equal 10
    end
  end

  describe 'best_account_analysis' do
    it 'should return nil_account_analysis when best_account_analysis is absent' do
      _(admin.best_account_analysis.class).must_equal NilAccountAnalysis
    end

    it 'should return best_account_analysis when available' do
      account_analysis = create(:best_account_analysis, account_id: account.id)
      account.update_column(:best_vita_id, account_analysis.id)
      _(account.best_account_analysis.class).must_equal AccountAnalysis
    end
  end

  describe 'most_experienced_language' do
    it 'should return nil when account_analysis_language_facts is empty' do
      _(admin.most_experienced_language).must_be_nil
    end

    it 'should return language name when account_analysis_language_facts is present' do
      account_analysis = create(:best_account_analysis, account_id: account.id)
      account.update_column(:best_vita_id, account_analysis.id)
      language_fact = create(:account_analysis_language_fact, vita_id: account_analysis.id)

      _(account.most_experienced_language.nice_name).must_equal language_fact.language.nice_name
    end
  end

  describe 'anonymous?' do
    it 'should return true for anonymous account' do
      account = AnonymousAccount.create!
      _(account.anonymous?).must_equal true
    end

    it 'should return false for normal account' do
      _(admin.anonymous?).must_equal false
    end
  end

  describe 'edit_count' do
    it 'should return the no of undone edits' do
      CreateEdit.create(target: admin, account_id: admin.id)
      CreateEdit.create(target: admin, account_id: admin.id, undone: true)
      _(admin.edit_count).must_equal 1
    end
  end

  describe 'badges' do
    it 'should return all eligible badges' do
      fosser_badge = Badge::FosserBadge.new(admin)
      Badge.stubs(:all_eligible).returns([fosser_badge])
      _(admin.badges).must_equal [fosser_badge]
    end
  end

  describe 'find_or_create_anonymous_account' do
    it 'should create anonymous account if it does not exist' do
      _(Account.find_or_create_anonymous_account.login).must_equal AnonymousAccount::LOGIN
    end

    it 'should find anonymous account if it exists' do
      anonymous_account = AnonymousAccount.create!
      _(Account.find_or_create_anonymous_account).must_equal anonymous_account
    end
  end

  describe 'resolve_login' do
    it 'should find account by login' do
      admin.update_column(:login, 'test')
      _(Account.resolve_login('Test')).must_equal admin
      _(Account.resolve_login('tEst')).must_equal admin
      _(Account.resolve_login('test')).must_equal admin
    end
  end

  describe 'ip' do
    it 'should return ip if defined' do
      admin.ip = '127.0.0.1'
      _(admin.ip).must_equal '127.0.0.1'
    end

    it 'should return ip as 0.0.0.0 if not defined' do
      _(admin.ip).must_equal '0.0.0.0'
    end
  end

  describe 'links' do
    it 'should return links' do
      project = create(:project)
      link = create(:link, project: project)
      CreateEdit.create!(target_id: link.id, project_id: project.id, target_type: 'Link', account_id: admin.id)

      _(admin.links).must_equal [link]
    end
  end

  describe 'resend_activation!' do
    it 'should resent activation email and update sent at timestamp' do
      ActionMailer::Base.deliveries.clear

      admin.resend_activation!
      email = ActionMailer::Base.deliveries.last
      _(email.to).must_equal [admin.email]
      _(email.subject).must_equal I18n.t('account_mailer.signup_notification.subject')
    end
  end

  describe 'run_actions' do
    it 'should run all actions for the account' do
      account = create(:account)
      project = create(:project)
      action = Action.create(account: account, stack_project: project, status: 'completed')

      account.reload
      account.run_actions('completed')
      action.reload
      _(action.status).must_equal Action::STATUSES[:remind]
    end
  end

  describe 'from_param' do
    it 'should match account login' do
      account = create(:account)
      _(Account.from_param(account.login).first.id).must_equal account.id
    end

    it 'should match account id as string' do
      account = create(:account)
      _(Account.from_param(account.id.to_s).first.id).must_equal account.id
    end

    it 'should match account id as integer' do
      account = create(:account)
      _(Account.from_param(account.id).first.id).must_equal account.id
    end

    it 'should not match spammers' do
      account = create(:account)
      _(Account.from_param(account.to_param).count).must_equal 1
      account.access.spam!
      _(Account.from_param(account.to_param).count).must_equal 0
    end
  end

  describe 'active' do
    it 'should return active accounts' do
      account1 = create(:account, level: -20)
      account2 = create(:account, level: 0)
      account3 = create(:account, level: 10)

      _(Account.active).wont_include account1
      _(Account.active).must_include account2
      _(Account.active).wont_include account3
    end
  end

  describe 'fetch_by_login_or_email' do
    it 'should match for upper case email' do
      account = create(:account)
      _(Account.fetch_by_login_or_email(account.email.upcase)).wont_be_nil
      fetch_account = Account.fetch_by_login_or_email(account.email.upcase)
      _(fetch_account).must_equal account
    end

    it 'should match for lower case email' do
      account = create(:account)
      _(Account.fetch_by_login_or_email(account.email.downcase)).wont_be_nil
      fetch_account = Account.fetch_by_login_or_email(account.email.downcase)
      _(fetch_account).must_equal account
    end

    it 'should match for mixed case email' do
      account = create(:account)
      _(Account.fetch_by_login_or_email(account.email.titlecase)).wont_be_nil
      fetch_account = Account.fetch_by_login_or_email(account.email.titlecase)
      _(fetch_account).must_equal account
    end

    it 'should match for upper case login' do
      account = create(:account)
      _(Account.fetch_by_login_or_email(account.login.upcase)).wont_be_nil
      fetch_account = Account.fetch_by_login_or_email(account.login.upcase)
      _(fetch_account).must_equal account
    end

    it 'should match for lower case login' do
      account = create(:account)
      _(Account.fetch_by_login_or_email(account.login.downcase)).wont_be_nil
      fetch_account = Account.fetch_by_login_or_email(account.email.downcase)
      _(fetch_account).must_equal account
    end
  end

  describe 'reverification_not_initiated' do
    it 'should return all unverified accounts that are in good standing with no associations' do
      account = create(:account)
      unverified_account = create(:unverified_account)
      SuccessfulAccounts.create(account_id: unverified_account.id)
      assert_equal Account.reverification_not_initiated(5).count, 1
      assert_equal Account.reverification_not_initiated(5)[0].id, unverified_account.id
      _(Account.reverification_not_initiated(5)).wont_include account
    end

    it 'should not include a spam account in the process' do
      spam_account = create(:unverified_account, :spammer)
      assert_equal Account.reverification_not_initiated(5).count, 0
      _(Account.reverification_not_initiated(5)).wont_include spam_account
    end

    it 'should not include an admin account in the process' do
      admin_account = create(:unverified_account, :admin)
      assert_equal Account.reverification_not_initiated(5).count, 0
      _(Account.reverification_not_initiated(5)).wont_include admin_account
    end

    it 'should not include a disabled account in the process' do
      disabled_account = create(:unverified_account, :disabled_account)
      assert_equal Account.reverification_not_initiated(5).count, 0
      _(Account.reverification_not_initiated(5)).wont_include disabled_account
    end

    it 'should not include an unverified account with edits' do
      account = create(:account, :no_verification)
      account.edits << create(:create_edit)
      account.edits[0].update!(account_id: account.id)
      unverified_account = create(:unverified_account)
      SuccessfulAccounts.create(account_id: unverified_account.id)
      assert_equal Account.reverification_not_initiated(5).count, 1
      assert_equal Account.reverification_not_initiated(5)[0].id, unverified_account.id
      _(Account.reverification_not_initiated(5)).wont_include account
    end

    it 'should not include an unverified account with posts' do
      account = create(:account, :no_verification)
      account.posts << create(:post)
      account.posts[0].update!(account_id: account.id)
      unverified_account = create(:unverified_account)
      SuccessfulAccounts.create(account_id: unverified_account.id)
      assert_equal Account.reverification_not_initiated(5).count, 1
      assert_equal Account.reverification_not_initiated(5)[0].id, unverified_account.id
      _(Account.reverification_not_initiated(5)).wont_include account
    end

    it 'should not include an unverified account with kudos (sender_id)' do
      kudo = create(:kudo)
      sender = kudo.sender
      account = kudo.account
      sender.verifications[0].destroy
      account.verifications[0].destroy
      SuccessfulAccounts.create(account_id: account.id)
      sender.reload
      account.reload
      assert_equal Account.reverification_not_initiated(5).count, 1
      assert_equal Account.reverification_not_initiated(5)[0].id, account.id
      _(Account.reverification_not_initiated(5)).wont_include sender
    end

    it 'should not include an unverified account with reviews' do
      account = create(:account, :no_verification)
      account.reviews << create(:review)
      account.reviews[0].update!(account_id: account.id)
      unverified_account = create(:unverified_account)
      SuccessfulAccounts.create(account_id: unverified_account.id)
      assert_equal Account.reverification_not_initiated(5).count, 1
      assert_equal Account.reverification_not_initiated(5)[0].id, unverified_account.id
      _(Account.reverification_not_initiated(5)).wont_include account
    end

    it 'should not include an unverified account with positions' do
      account = create(:account, :no_verification)
      account.positions << create(:position)
      account.positions[0].update!(account_id: account.id)
      unverified_account = create(:unverified_account)
      SuccessfulAccounts.create(account_id: unverified_account.id)
      assert_equal Account.reverification_not_initiated(5).count, 1
      assert_equal Account.reverification_not_initiated(5)[0].id, unverified_account.id
      _(Account.reverification_not_initiated(5)).wont_include account
    end

    it 'should not include an unverified account with stacks' do
      account = create(:account, :no_verification)
      account.stacks << create(:stack)
      account.stacks[0].update!(account_id: account.id)
      unverified_account = create(:unverified_account)
      SuccessfulAccounts.create(account_id: unverified_account.id)
      assert_equal Account.reverification_not_initiated(5).count, 1
      assert_equal Account.reverification_not_initiated(5)[0].id, unverified_account.id
      _(Account.reverification_not_initiated(5)).wont_include account
    end

    it 'should not include an unverified account that manage' do
      manage = create(:manage)
      manage.account.github_verification.destroy
      manage.reload
      unverified_account = create(:unverified_account)
      SuccessfulAccounts.create(account_id: unverified_account.id)
      assert_equal Account.reverification_not_initiated(5).count, 1
      assert_equal Account.reverification_not_initiated(5)[0].id, unverified_account.id
      _(Account.reverification_not_initiated(5)).wont_include manage
    end
  end

  describe 'destroy' do
    it 'must delete an Alias for an unverified account on account.destroy' do
      unverified_account = create(:position_with_unverified_account).account
      Alias.any_instance.stubs(:schedule_project_analysis)
      position = unverified_account.positions.first
      project = position.project
      commit_id = create(:name).id

      alias1 = create(:alias, project_id: project.id, commit_name_id: commit_id, preferred_name_id: position.name_id)
      alias1.create_edit.account = unverified_account
      alias1.create_edit.save
      _(alias1.reload.deleted).must_equal false

      unverified_account.destroy
      _(alias1.reload.deleted).must_equal true
    end

    it 'must delete a protected Alias for a non manager account on account.destroy' do
      account = create(:position).account
      Alias.any_instance.stubs(:schedule_project_analysis)
      position = account.positions.first
      project = position.project
      commit_id = create(:name).id

      alias1 = create(:alias, project_id: project.id, commit_name_id: commit_id, preferred_name_id: position.name_id)
      alias1.create_edit.account = account
      alias1.create_edit.save
      _(alias1.reload.deleted).must_equal false

      # Enable acts_as_protected.
      create(:permission, target: project, remainder: true)

      account.destroy
      _(alias1.reload.deleted).must_equal true
    end
  end

  describe 'recent_kudos' do
    let(:kudos) { [] }
    before do
      4.times { |n| kudos << create(:kudo, sender: admin, account: account, created_at: n.day.ago) }
    end

    it 'should return 3 recent kudos as default limit' do
      _(account.recent_kudos.to_a).must_equal kudos.take(3)
    end

    it 'should return recent kudos upon argumented limit' do
      _(account.recent_kudos(4).to_a).must_equal kudos
    end
  end

  describe 'create_manual_verification' do
    it 'should create a manual verification object for one account' do
      unverified_account = create(:position_with_unverified_account).account
      assert_equal [], unverified_account.verifications
      _(unverified_account.manual_verification).must_be_nil
      assert_difference('ManualVerification.count', 1) do
        unverified_account.create_manual_verification
      end
    end
  end
end
