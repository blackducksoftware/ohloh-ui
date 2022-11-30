# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start('rails') do
  add_filter %r{^script/}
end
SimpleCov.minimum_coverage 99.45

require 'dotenv'
Dotenv.load '.env.test'

require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'minitest/rails'
require 'mocha/minitest'
require 'test_helpers/setup_hamster_account'
require 'test_helpers/create_forges'
require 'test_helpers/api_factories'
require 'sidekiq/testing'
require 'webmock/minitest'
require 'test_helpers/web_mocker'
require 'clearance/test_unit'

Sidekiq::Testing.fake!

ActiveRecord::Migration.maintain_test_schema!

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
end

class ActiveSupport::TestCase
  extend SetupHamsterAccount
  extend CreateForges
  extend MiniTest::Spec::DSL
  include FactoryBot::Syntax::Methods

  TEST_PASSWORD = :test_password

  create_hamster_account
  create_forges

  def login_as(account)
    request && request.env[:clearance] ? controller_login_as(account) : integration_login_as(account)
  end

  def create_must_and_wont_aliases(*classes)
    classes.each do |klass|
      klass.send(:alias_method, :wont, :wont_be)
      klass.send(:alias_method, :must, :must_be)
    end
  end

  def as(user)
    login_as user
    yield if block_given?
  end
  alias edit_as as

  def get_contribution
    create(:name_with_fact)
    name_fact = NameFact.last
    Person.rebuild_by_project_id(name_fact.analysis.project_id)
    Contribution.find_by(name_fact_id: name_fact.id)
  end

  def stub_constant(klass, const, value)
    old = klass.const_get(const)
    klass.send(:remove_const, const)
    klass.const_set(const, value)
    yield
  ensure
    klass.send(:remove_const, const)
    klass.const_set(const, old)
  end

  private

  def controller_login_as(account)
    if account
      request.env[:clearance].sign_in(account)
    else
      request.env[:clearance].sign_out
    end
  end

  def integration_login_as(account)
    if account
      get new_session_path
      post sessions_path, params: { login: { login: account.login, password: TEST_PASSWORD } }
    else
      delete sessions_path
    end
  end

  def create_position(attributes = {})
    project = attributes[:project] || create(:project)
    name_fact = create(:name_fact, analysis: project.best_analysis, name: attributes[:name] || create(:name))
    create :position, { name: name_fact.name, project: project }.merge(attributes)
  end

  def i18n_activerecord(model, key)
    I18n.t("activerecord.errors.models.#{model}.attributes.#{key}")
  end

  def restrict_edits_to_managers(organization_or_project, account = create(:account))
    organization_or_project.update! editor_account: account
    permission = organization_or_project.create_permission
    permission.update!(remainder: true, editor_account: account)
  end

  def create_account_with_commits_by_project
    account_analysis = create(:best_account_analysis)
    account = account_analysis.account
    position1 = create_position(account: account)
    position2 = create_position(account: account)
    account_analysis.account_analysis_fact.update!(
      commits_by_project: CommitsByProjectData.new(position1.id, position2.id).construct,
      commits_by_language: CommitsByLanguageData.construct
    )
    account.reload.best_account_analysis.reload.account_analysis_fact.reload
    account
  end

  def create_account_with_commits_by_language
    account_analysis = create(:best_account_analysis)
    account = account_analysis.account
    account_analysis.account_analysis_fact.update!(commits_by_language: CommitsByLanguageData.construct)
    account.reload.best_account_analysis.reload.account_analysis_fact.reload
    account
  end

  def create_project_and_analysis
    (0..2).each do |value|
      2.times do
        project = create(:project)
        analysis = create(:analysis, oldest_code_set_time: Date.current - value.days, project: project)
        project.update(best_analysis: analysis)
      end
    end
  end

  def stub_code_location_subscription_api_call(code_location_id, project_id, method = 'create', &block)
    VCR.use_cassette("#{method}_code_location_subscription",
                     erb: { code_location_id: code_location_id, client_relation_id: project_id },
                     match_requests_on: %i[host path method], &block)
  end

  def stub_firebase_verification(sub = '123', alg = 'RS256', kid = '745c7128cba10e251b9fe712aed52613388a6699')
    [{ 'iss' => 'https://securetoken.google.com/fir-sample-8bb3e',
       'aud' => 'fir-sample-8bb3e',
       'auth_time' => 1_505_737_344,
       'user_id' => '123',
       'sub' => sub,
       'iat' => 1_505_737_344,
       'exp' => 1_505_740_944,
       'phone_number' => '+919999999999',
       'firebase' => { 'identities' => { 'phone' => ['+919999999999'] },
                       'sign_in_provider' => 'phone' } },
     { 'alg' => alg,
       'kid' => kid },
     nil]
  end

  def assert_response(code)
    assert_response(code)
  end
end
