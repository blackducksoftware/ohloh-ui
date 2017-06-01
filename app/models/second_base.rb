class SecondBase < ActiveRecord::Base
  self.abstract_class = true
  unless Rails.env == 'test'
    establish_connection Rails.configuration.database_configuration['secondbase'][Rails.env]
  end
end
