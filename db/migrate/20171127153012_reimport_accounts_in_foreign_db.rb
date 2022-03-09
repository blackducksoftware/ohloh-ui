# frozen_string_literal: true

class ReimportAccountsInForeignDb < ActiveRecord::Migration[4.2]
  def up
    SecondBase::Base.connection.execute('DROP FOREIGN TABLE accounts;')
    SecondBase::Base.connection
                    .execute('IMPORT FOREIGN SCHEMA public LIMIT TO (accounts) FROM SERVER ohloh INTO public;')
  end
end
