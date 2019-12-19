# frozen_string_literal: true

class FirebaseVerification < Verification
  attr_accessor :credentials

  validates :credentials, presence: true

  before_validation :generate_token, on: :create

  private

  def generate_token
    firebase = FirebaseService.new(ENV['FIREBASE_PROJECT_ID'])
    decoded_token = firebase.decode(credentials)
    if decoded_token
      self.token = decoded_token[0]['user_id']
      self.unique_id = token
    else
      errors.add(:unique_id, 'Phone Verification failed please try again')
    end
  end
end
