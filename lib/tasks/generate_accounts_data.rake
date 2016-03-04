# Usage:
# rake selenium:prepare_accounts_data ACCOUNT_NAME=stefan

include ActionView::Helpers::DateHelper

OUTPUT_FILE = 'tmp/accounts_data.yml'

namespace :selenium do
  file :generate_data do
    File.open(OUTPUT_FILE, 'w+') do |file|
      file.write(@accounts_data.to_yaml)
    end
  end

  desc 'Prepare Accounts data for selenium'
  task prepare_accounts_data: [:set_account, :account_summary, :generate_data]

  task set_account: :environment do
    @account = Account.from_param(ENV['ACCOUNT_NAME']).take

    abort "Account(#{ENV['ACCOUNT_NAME']}) not found" unless @account

    @accounts_data = @account.attributes
  end

  task account_summary: :environment do
    account_summary = {
      'last_analysed' =>
        @account.best_vita.nil? ? nil : "Analyzed #{time_ago_in_words(@account.best_vita.try(:created_at))} ago",
      'description' => @account.markup.try(:formatted),
      'projects_used' => @account.projects.map(&:to_param),
      'most_exp_lang' => @account.most_experienced_language.try(:nice_name),
      'baseballcard' => BaseballCard.new(@account).rows.collect { |row| row[:value] || row[:locals][:orgs].map(&:name) }
    }

    @accounts_data['account_summary'] = account_summary
  end
end
