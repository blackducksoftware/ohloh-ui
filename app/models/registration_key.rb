class RegistrationKey < ActiveRecord::Base
  validates :client_name, presence: true, uniqueness: true
end
