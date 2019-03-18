class FisBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection SecondBase.config unless Rails.env.test?
end
