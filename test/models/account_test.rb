require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  it '#sent_kudos' do
    Kudo.delete_all
    admin_account = accounts(:admin)
    create(:kudo, sender: admin_account, account: accounts(:user))
    create(:kudo, sender: admin_account, account: accounts(:joe))

    admin_account.sent_kudos.count.must_equal 2
  end

  it '#claimed_positions' do
    user = create(:account)
    proj = create(:project)
    create(:position, account: user, project: proj)
    user.positions.count.must_equal 1
    user.claimed_positions.count.must_equal 1
  end

  it 'the account model should be valid' do
    account = build(:account)
    account.must_be :valid?
  end

  it 'it should validate email and email_confirmation' do
    account = build(:account)
    account.email = 'ab'
    account.wont_be :valid?
    account.errors.must_include(:email)
    account.errors.must_include(:email_confirmation)
    expected_error_message = ['is too short (minimum is 3 characters)', I18n.t('accounts.invalid_email_address')]
    account.errors.messages[:email].must_equal expected_error_message
    account.errors.messages[:email_confirmation].must_equal ['doesn\'t match Email']
  end

  it 'it should validate URL format when value is available' do
    account = build(:account)
    account.must_be :valid?

    account = build(:account, url: '')
    account.must_be :valid?

    account = build(:account, url: 'openhub.net')
    account.wont_be :valid?
    account.errors.must_include(:url)
    account.errors.messages[:url].first.must_equal I18n.t('accounts.invalid_url_format')
  end

  it 'it should validate login' do
    account = build(:account)
    account.must_be :valid?

    account = build(:account, login: '')
    account.wont_be :valid?
    expected_error_message =
      ['can\'t be blank', 'is too short (minimum is 3 characters)',
       I18n.t('activerecord.errors.models.account.attributes.login.invalid')]
    account.errors.messages[:login].must_equal expected_error_message

    create(:account, login: 'openhub_dev')
    account = build(:account, login: 'openhub_dev')
    account.wont_be :valid?
    account.errors.must_include(:login)
    account.errors.messages[:login].must_equal ['has already been taken']
  end

  it 'it should validate password' do
    account = build(:account)
    account.must_be :valid?

    account = build(:account, password: '')
    account.wont_be :valid?
    account.errors.must_include(:password)
    account.errors.messages[:password].first.must_equal I18n.t(:cant_be_blank)
    account.errors.messages[:password_confirmation].must_equal ['doesn\'t match Password']

    account = build(:account, password: 'abc12345', password_confirmation: 'ABC12345')
    account.wont_be :valid?
    account.errors.must_include(:password_confirmation)
    account.errors.messages[:password_confirmation].must_equal ['doesn\'t match Password']
  end

  it 'it should validate twitter account only if its present' do
    account = build(:account)
    account.must_be :valid?

    account = build(:account, twitter_account: '')
    account.must_be :valid?

    account = build(:account, twitter_account: 'abcdefghijklmnopqrstuvwxyz')
    account.wont_be :valid?
    account.errors.must_include(:twitter_account)
    account.errors.messages[:twitter_account].must_equal ['is too long (maximum is 15 characters)']
  end

  it 'it should validate user full name' do
    account = build(:account)
    account.must_be :valid?

    account = build(:account, name: '')
    account.must_be :valid?

    account = build(:account, name: Faker::Name.name * 8)
    account.wont_be :valid?
    account.errors.must_include(:name)
    account.errors.messages[:name].must_equal ['is too long (maximum is 50 characters)']
  end

  it 'it should update the markup(about me) when updating a record' do
    account = create(:account)
    about_me = Faker::Lorem.paragraph(2)
    account.about_raw = about_me
    account.save
    account.markup.raw.must_equal about_me
  end

  it 'it should not update the markup(about me) when exceeding the limit' do
    account = create(:account)
    about_me = Faker::Lorem.paragraph(130)
    account.about_raw = about_me
    account.wont_be :valid?
    account.markup.errors.must_include(:raw)
  end

  it 'it should error out when affiliation_type is not specified' do
    account = create(:account)
    account.affiliation_type = ''
    account.wont_be :valid?
    account.errors.must_include(:affiliation_type)
    account.errors.messages[:affiliation_type].first.must_equal I18n.t(:is_invalid)
  end

  it 'should search by login and sort by position and char length' do
    create(:account, login: 'test')
    create(:account, login: 'account_test', email: 'test2@openhub.net', email_confirmation: 'test2@openhub.net')
    create(:account, login: 'tester', email: 'test3@openhub.net', email_confirmation: 'test3@openhub.net')
    create(:account, login: 'unittest', email: 'test4@openhub.net', email_confirmation: 'test4@openhub.net')
    create(:account, login: 'unittest1', email: 'test5@openhub.net', email_confirmation: 'test5@openhub.net')
    account_search = Account.simple_search('test')
    account_search.size.must_equal 5
    account_search.first.login.must_equal 'test'
    account_search.second.login.must_equal 'tester'
    account_search.third.login.must_equal 'unittest'
    account_search.fourth.login.must_equal 'unittest1'
    account_search.fifth.login.must_equal 'account_test'
  end

  it 'should return recently active accounts' do
    name_facts(:vitafact).update_attributes(last_checkin: Time.now)
    recently_active = Account.recently_active
    recently_active.wont_be_nil
    recently_active.count.must_equal 1
  end

  it 'should not return non recently active accounts' do
    recently_active = Account.recently_active
    recently_active.must_be_empty
    recently_active.count.must_equal 0
  end

  it 'it should error out when affiliation_type is specified and org name is blank' do
    account = create(:account)
    account.affiliation_type = 'specified'
    account.organization_id = ''
    account.wont_be :valid?
    account.errors.must_include(:organization_id)
    account.errors.messages[:organization_id].first.must_equal I18n.t(:cant_be_blank)
  end

  it 'facts_joins should accounts with positions projects and name_facts' do
    analysis = analyses(:linux)
    project = projects(:linux)
    project.editor_account = create(:account)
    project.update_attributes! best_analysis_id: analysis.id

    accounts_with_facts = Account.with_facts
    accounts_with_facts.size.must_equal 2
    accounts_with_facts.first.name.must_equal 'admin Allen'
    accounts_with_facts.last.name.must_equal 'user Luckey'
  end

  it 'should validate current password error message' do
    account = accounts(:user)
    account.current_password = 'dummy password'
    refute account.valid?
    account.errors.size.must_equal 1
    error_message = [I18n.t('activerecord.errors.models.account.attributes.current_password.invalid')]
    error_message.must_equal account.errors[:current_password]
  end

  it 'should not raise error for valid current password' do
    account = accounts(:user)
    account.current_password = 'test'
    account.must_be :valid?
    account.errors.size.must_equal 0
  end

  it 'it should get the first commit date for a account position' do
    user = accounts(:user)
    expected_date = Time.strptime('2008-02-09', '%Y-%m-%d').to_date.beginning_of_month
    user.first_commit_date.must_equal expected_date
  end

  it 'it should return nil when account has no best_vita' do
    user = accounts(:admin)
    user.first_commit_date.must_be_nil
  end

  describe 'login validations' do
    it 'test should require login' do
      assert_no_difference 'Account.count' do
        account = build(:account, login: nil)
        account.valid?
        account.errors.messages[:login].must_be :present?
      end
    end

    it 'test valid logins' do
      account = build(:account)
      logins = %w(rockola ROCKOLA Rockola Rock_Ola F323)

      logins.each do |login|
        account.login = login
        account.must_be :valid?
      end
    end

    it 'test login not urlable' do
      account = build(:account)
      bad_logins = %w(123 user.allen $foo])

      bad_logins.each do |bad_login|
        account.login = bad_login
        account.wont_be :valid?
      end
    end

    it 'test bad login on create' do
      account = build(:account, login: '$foo')
      account.valid?
      account.errors.messages[:login].must_be :present?
    end

    it 'test login on update' do
      # fake a bad login already in the db
      account = accounts(:user)
      account.login = '$bad_login$'
      account.save(validate: false).wont_equal false

      # ok, now update something else than login
      account.reload
      account.name = 'My New Name'
      account.save.wont_equal false

      # ok, now try updating the name to something new, yet still wrong
      account.reload
      account.login = '$another_bad_login$'
      account.save.must_equal false
      account.errors.messages[:login].must_be :present?
    end
  end

  describe 'most_experienced_language' do
    it 'should return C as Logic as the most exp language despite make having more commits in Make Lang' do
      skip 'FIXME: Integrate alongwith Language, vita'
      make = Language.create(name: :make, nice_name: :Make, category: 2)
      generate_vita_user
      vita = accounts(:user).best_vita
      NameLanguageFact.create(language_id: make.id, total_commits: 300,
                              vita_id: vita.id, total_activity_lines: 200, total_months: 30)
      languages(:c).nice_name.must_equal accounts(:user).most_experienced_language.nice_name
    end

    it 'should return Make as the most exp language when C has no commits' do
      skip 'FIXME: Integrate alongwith Language, vita'
      make = Language.create(name: :make, nice_name: :Make, category: 2)
      generate_vita_user
      VitaLanguageFact.find_by_language_id(languages(:c).id).delete
      vita = accounts(:user).best_vita
      VitaLanguageFact.create(language_id: make.id, total_commits: 300,
                              vita_id: vita.id, total_activity_lines: 200, total_months: 30)
      make.nice_name.must_equal accounts(:user).most_experienced_language.nice_name
    end

    it 'should return HAML as the most exp language when C/Make has no commits' do
      skip 'FIXME: Integrate alongwith Language, vita'
      make = Language.create(name: :make, nice_name: :Make, category: 2)
      haml = Language.create(name: :haml, nice_name: :Haml, category: 1)
      generate_vita_user
      VitaLanguageFact.find_by_language_id(languages(:c).id).delete
      vita = accounts(:user).best_vita
      VitaLanguageFact.create(language_id: make.id, total_commits: 300, vita_id: vita.id,
                              total_activity_lines: 200, total_months: 30)
      VitaLanguageFact.create(language_id: haml.id, total_commits: 200, vita_id: vita.id,
                              total_activity_lines: 200, total_months: 30)
      haml.nice_name.must_equal accounts(:user).most_experienced_language.nice_name
    end
  end

  describe 'to_param' do
    it 'must return login when it is urlable' do
      account = build(:account, login: 'stan')
      account.to_param.must_equal account.login
    end

    it 'must return id when login is not urlable' do
      account = accounts(:user)
      account.login = '$one'
      account.to_param.must_equal account.id.to_s
    end
  end

  it '#email_topics' do
    account = accounts(:admin)
    account.email_topics?.must_equal true
    account.email_master = true
    account.email_posts = false
    account.email_topics?.must_equal false
    account.email_master = true
    account.email_posts = true
    account.email_topics?.must_equal true
    account.email_master = false
    account.email_posts = true
    account.email_topics?.must_equal false
  end

  it '#email_kudos' do
    account = accounts(:admin)
    account.email_kudos?.must_equal true
    account.email_master = true
    account.email_kudos = false
    account.email_kudos?.must_equal false
    account.email_master = true
    account.email_kudos = true
    account.email_kudos?.must_equal true
    account.email_master = false
    account.email_kudos = true
    account.email_kudos?.must_equal false
  end

  it '#update_akas' do
    create(:position, project: projects(:ohloh), name: names(:scott), account: accounts(:user))
    accounts(:user).update_akas
    accounts(:user).akas.split("\n").sort.must_equal %w(Scott User)
  end

  it '#links' do
    skip 'FIXME: Integrate alongwith edits'
    account = create(:account)
    linux = projects(:linux)
    linux.editor_account = account
    link = linux.links.new(
      url: 'http://www.google.com',
      title: 'title',
      link_category_id: Link::CATEGORIES[:Other]
    )
    link.editor_account = account
    link.save!
    account.links.must_include(link)
  end

  it 'badges list' do
    skip 'FIXME: Integrate alongwith Badge.'
    account = accounts(:user)
    badges = %w(badge1 badge2)
    Badge.expects(:all_eligible).with(account).returns(badges)
    account.badges.must_equal badges
  end

  it '#non_human_ids' do
    ohloh_slave_id = Account.hamster.id
    uber_data_crawler_id = Account.uber_data_crawler.id

    Account.non_human_ids.size.must_equal 2
    Account.non_human_ids.must_include(ohloh_slave_id)
    Account.non_human_ids.must_include(uber_data_crawler_id)
  end

  describe 'validations' do
    it 'should require password' do
      assert_no_difference 'Account.count' do
        user = build(:account, password: nil)
        user.valid?
        user.errors.messages[:password].must_be :present?
      end
    end

    it 'should require password confirmation' do
      assert_no_difference 'Account.count' do
        user = build(:account, password_confirmation: nil)
        user.valid?
        user.errors.messages[:password_confirmation].must_be :present?
      end
    end

    it 'it should require email confirmation' do
      assert_no_difference 'Account.count' do
        user = build(:account, email_confirmation: '')
        user.valid?
        user.errors.messages[:email_confirmation].must_be :present?
        user.errors.messages[:email_confirmation].first.must_equal %(doesn't match Email)
      end
    end

    it 'email & email confirmation shouldn\'t be blank' do
      assert_no_difference 'Account.count' do
        user = build(:account, email_confirmation: '', email: '')
        user.valid?
        user.errors.messages[:email_confirmation].must_be :present?

        user.errors.messages[:email_confirmation].first.must_equal I18n.t('accounts.invalid_email_address')
      end
    end

    it 'email & email confirmation is blank and should raise error' do
      assert_no_difference 'Account.count' do
        user = build(:account, email_confirmation: '', email: 'rapbhan@rapbhan.com')
        user.valid?
        user.errors.messages[:email_confirmation].must_be :present?
        user.errors.messages[:email_confirmation].first.must_equal %(doesn't match Email)
      end
    end

    it 'must validate format of organization_name' do
      account = build(:account)
      account.affiliation_type = 'other'
      account.organization_name = '_org'
      account.valid?

      message = I18n.t('activerecord.errors.models.account.attributes.organization_name.invalid')
      account.errors.messages[:organization_name].first.must_equal message
    end

    it 'must validated length of organization_name' do
      account = build(:account)
      account.affiliation_type = 'other'
      account.organization_name = 'A1'
      account.valid?

      message = 'is too short (minimum is 3 characters)'
      account.errors.messages[:organization_name].first.must_equal message
    end

    it 'must allow blank organization_name' do
      account = build(:account)
      account.affiliation_type = 'specified'
      account.organization_name = ''
      account.valid?

      account.errors.messages[:organization_name].must_be_nil
    end
  end

  it 'disallow html tags in url' do
    account = create(:account, url: 'http://www.ohloh.net/')
    account.must_be :valid?

    account.url = %q(http://1.cc/ <img src="s" onerror="top.location=' http://vip-feed.com/35898/buy+adderall.html';">)
    account.wont_be :valid?
    account.errors.messages[:url].must_be :present?
  end

  it 'deleting an account creates a organization job for the org' do
    skip('TODO: Organization job should be scheduled for account organization_id update')
    accounts(:robin).update_attribute(:organization_id, organizations(:google).id)
    org_id = accounts(:robin).organization_id
    Job.delete_all
    accounts(:robin).destroy
    OrganizationJob.count.must_equal 1
    OrganizationJob.first.organization_id.must_equal org_id
  end

  it 'updating an account with different org id creates organization jobs for the affected orgs' do
    skip('TODO: Organization job should be scheduled for account organization_id update')
    accounts(:robin).update_attribute(:organization_id, organizations(:google).id)
    Job.delete_all
    accounts(:robin).reload.update_attributes!(organization_id: organizations(:linux).id)
    OrganizationJob.count.must_equal 2
  end

  describe 'kudo_rank' do
    it 'should return 1 if kudo_rank is nil' do
      accounts(:admin).person.update_column(:kudo_rank, nil)
      accounts(:admin).kudo_rank.must_equal 1
    end

    it 'should return kudo_rank' do
      accounts(:user).kudo_rank.must_equal 10
    end
  end
end
