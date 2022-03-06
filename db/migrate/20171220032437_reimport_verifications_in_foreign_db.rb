# frozen_string_literal: true

class ReimportVerificationsInForeignDb < ActiveRecord::Migration[4.2]
  def change
    SecondBase::Base.connection.execute('DROP FOREIGN TABLE verifications;')
    SecondBase::Base.connection
                    .execute('IMPORT FOREIGN SCHEMA public LIMIT TO (verifications) FROM SERVER ohloh INTO public;')
  end
end
