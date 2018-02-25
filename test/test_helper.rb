ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'
SimpleCov.minimum_coverage 99.58

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails'
require 'mocha/mini_test'
require 'dotenv'
require 'test_helpers/setup_hamster_account'
require 'test_helpers/create_forges'
require 'test_helpers/api_factories'
require 'sidekiq/testing'
require 'webmock/minitest'
require 'test_helpers/web_mocker'
require 'clearance/test_unit'

Sidekiq::Testing.fake!

Dotenv.overload '.env.test'

ActiveRecord::Migration.maintain_test_schema!

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  extend SetupHamsterAccount
  extend CreateForges
  extend MiniTest::Spec::DSL
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
    Contribution.find_by_name_fact_id(name_fact.id)
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
      post sessions_path, login: { login: account.login, password: TEST_PASSWORD }
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
    vita = create(:best_vita)
    account = vita.account
    position1 = create_position(account: account)
    position2 = create_position(account: account)
    vita.vita_fact.update!(commits_by_project: CommitsByProjectData.new(position1.id, position2.id).construct,
                           commits_by_language: CommitsByLanguageData.construct)
    account.reload.best_vita.reload.vita_fact.reload
    account
  end

  def create_account_with_commits_by_language
    vita = create(:best_vita)
    account = vita.account
    vita.vita_fact.update!(commits_by_language: CommitsByLanguageData.construct)
    account.reload.best_vita.reload.vita_fact.reload
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

  def stub_code_location_subscription_api_call(method = 'create')
    VCR.use_cassette("#{method}_code_location_subscription", match_requests_on: [:host, :path, :method]) do
      yield
    end
  end

  def stub_firebase_verification(sub = '123', alg = 'RS256', kid = '745c7128cba10e251b9fe712aed52613388a6699')
    decoded_val = [{  'iss' => 'https://securetoken.google.com/fir-sample-8bb3e',
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
    decoded_val
  end

  def stub_github_user_repositories_call
    # rubocop:disable NestedMethodDefinition
    class << Open3
      def popen3_with_change(_command, github_url)
        return if github_url =~ /page=2/
        file_path = File.expand_path('../data/github_user_repos.json', __FILE__)
        [nil, File.read(file_path)]
      end

      alias_method :popen3_without_change, :popen3
      alias_method :popen3, :popen3_with_change
    end

    yield

    class << Open3
      alias_method :popen3, :popen3_without_change
    end
    # rubocop:enable NestedMethodDefinition
  end
end
