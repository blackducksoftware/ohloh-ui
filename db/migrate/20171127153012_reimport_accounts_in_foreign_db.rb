class ReimportAccountsInForeignDb < ActiveRecord::Migration
  def up
    SecondBase::Base.connection.execute('DROP FOREIGN TABLE accounts;')
    SecondBase::Base.connection
                    .execute('IMPORT FOREIGN SCHEMA public LIMIT TO (accounts) FROM SERVER ohloh INTO public;')
  end
end
