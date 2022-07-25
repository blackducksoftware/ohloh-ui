# frozen_string_literal: true

class SpamController < ApplicationController
  def redirect_to_first_potential_spammer
    sql = <<-SQL.squish
             SELECT id FROM oh.potential_spammers LIMIT 1;
    SQL
    result = ActiveRecord::Base.connection.execute(sql)
    if result.num_tuples.positive?
      account = Account.find(result[0]['id'])
      redirect_to account_path(account)
    else
      redirect_to admin_path
    end
  end
end
