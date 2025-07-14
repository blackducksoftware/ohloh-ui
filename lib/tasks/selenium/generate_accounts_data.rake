# frozen_string_literal: true

# Usage:
# rake selenium:prepare_accounts_data ACCOUNT_NAME=stefan

OUTPUT_FILE = 'tmp/accounts_data.yml'

namespace :selenium do
  include ActionView::Helpers::DateHelper

  file :generate_data do
    File.write(OUTPUT_FILE, @accounts_data.to_yaml)
  end

  desc 'Prepare Accounts data for selenium'
  task prepare_accounts_data: %i[set_account account_summary generate_data]

  task set_account: :environment do
    @account = Account.from_param(ENV.fetch('ACCOUNT_NAME', nil)).take

    abort "Account(#{ENV.fetch('ACCOUNT_NAME', nil)}) not found" unless @account

    @accounts_data = @account.attributes
  end

  task account_summary: :environment do
    best_analysis = @account.best_account_analysis
    account_summary = {
      'last_analysed' =>
        @account.best_account_analysis.nil? ? nil : "Analyzed #{time_ago_in_words(best_analysis.try(:created_at))} ago",
      'description' => @account.markup.try(:formatted),
      'projects_used' => Project.active.joins(:stacks).where(stacks: { account_id: @account.id })
                                .order(:user_count, :name).limit(15).distinct.map(&:to_param),
      'most_exp_lang' => @account.most_experienced_language.try(:nice_name),
      'baseballcard' => BaseballCard.new(@account).rows.collect { |row| row[:value] || row[:locals][:orgs].map(&:name) }
    }

    @accounts_data['account_summary'] = account_summary
  end
end
