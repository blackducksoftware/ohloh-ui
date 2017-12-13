class RegistrationKey < ActiveRecord::Base
  establish_connection SecondBase.config unless Rails.env == 'test'
  validates :client_name, presence: true, uniqueness: true
end
