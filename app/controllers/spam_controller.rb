# frozen_string_literal: true

class SpamController < ApplicationController
  before_action :session_required, only: %i[redirect_to_first_potential_spammer]
  before_action :admin_session_required, only: %i[redirect_to_first_potential_spammer]

  def redirect_to_first_potential_spammer
    sql = 'SELECT id FROM oh.potential_spammers ORDER BY random() LIMIT 1;'
    result = ActiveRecord::Base.connection.execute(sql)
    if result.num_tuples.positive?
      account = Account.find(result[0]['id'])
      redirect_to account_path(account)
    else
      redirect_to admin_path
    end
  end
end
