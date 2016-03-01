ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'
SimpleCov.minimum_coverage 99.55

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails'
require 'mocha/mini_test'
require 'dotenv'
require 'test_helpers/setup_hamster_account'
require 'test_helpers/create_forges'
Dotenv.overload '.env.test'

ActiveRecord::Migration.maintain_test_schema!

# VCR.configure do |config|
#   config.cassette_library_dir = 'fixtures/vcr_cassettes'
#   config.hook_into :webmock
# end

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  extend SetupHamsterAccount
  extend CreateForges
  extend MiniTest::Spec::DSL

  create_hamster_account
  create_forges

  before do
    GithubVerification.any_instance.stubs(:generate_access_token)
  end

  def login_as(account)
    @controller ? controller_login_as(account) : integration_login_as(account)
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
  alias_method :edit_as, :as

  def get_contribution
    create(:name_with_fact)
    name_fact = NameFact.last
    Person.rebuild_by_project_id(name_fact.analysis.project_id)
    Contribution.find_by_name_fact_id(name_fact.id)
  end

  private

  def controller_login_as(account)
    @controller.session[:account_id] = account ? account.id : nil
  end

  def integration_login_as(account)
    if account
      get new_session_path
      post sessions_path, login: { login: account.email, password: account.password }
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
        analysis = create(:analysis, logged_at: Date.current - value.days, project: project)
        project.update(best_analysis: analysis)
      end
    end
  end

  def stub_github_verification
    GithubVerification.any_instance.unstub(:generate_access_token)

    response = stub(body: nil, code: '200')
    Net::HTTP.any_instance.stubs(:send_request).returns(response)

    access_token = Faker::Internet.password
    data = { 'access_token' => [access_token] }
    CGI.stubs(:parse).returns(data)

    access_token
  end

  def stub_twitter_digits_verification
    response = stub(body: nil, code: '200')
    Net::HTTP.any_instance.stubs(:get2).returns(response)

    digits_id = Faker::Internet.password
    data = { 'id_str' => digits_id }
    JSON.stubs(:parse).returns(data)

    digits_id
  end

  # Note: These classes are used for mocking Reverification AWS::SimpleEmailService responses and messages.
  #        Used for the spammer cleanup initiative.
  class UndeterminedBody
    def body_message_as_h
      { 'bounce': { 'bounceType': 'Undetermined',
                    'bouncedRecipients': [{ 'emailAddress': 'someone@gmail.com' }]
        }
      }.with_indifferent_access
    end
  end

  class UndeterminedMessage
    def as_sns_message
      UndeterminedBody.new
    end
  end

  class HardBounceBody
    def body_message_as_h
      { 'bounce': { 'bounceType': 'Permanent',
                    'bouncedRecipients': [{ 'emailAddress': 'bounce@simulator.amazonses.com' }]
        }
      }.with_indifferent_access
    end
  end

  class HardBounceMessage
    def as_sns_message
      HardBounceBody.new
    end
  end

  class SuccessBody
    def body_message_as_h
      { 'delivery':
          { 'recipients': ['success@simulator.amazonses.com'] }
      }.with_indifferent_access
    end
  end

  class SuccessMessage
    def as_sns_message
      SuccessBody.new
    end
  end

  class TransientBounceBody
     def body_message_as_h
       { 'bounce': { 'bounceType': 'Transient',
                     'bouncedRecipients': [{ 'emailAddress': 'ooto@simulator.amazonses.com' }]
         }
       }.with_indifferent_access
     end
   end

  class TransientBounceMessage
    def as_sns_message
      TransientBounceBody.new
    end

    def body
      'ooto@simulator.amazonses.com'
    end
  end

  def aws_response_message_id
    { message_id: '78765357-sb87cccv-38374602-ghdku3846-gvoekgueta'}
  end

  class TransientQueueMessage
    def body
      'ooto@simulator.amazon.ses.com'
    end
  end
end
