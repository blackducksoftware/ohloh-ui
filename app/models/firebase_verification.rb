class FirebaseVerification < Verification
  attr_accessor :credentials

  validates :credentials, presence: true

  before_validation :generate_auth_id, on: :create

  private

  def generate_auth_id
    firebase = FirebaseService.new(ENV['FIREBASE_APP_ID'])
    decoded_token = firebase.decode(credentials)
    if decoded_token
      self.auth_id = decoded_token[0]['user_id']
    else
      errors.add(:auth_id, 'Phone Verification failed please try again')
    end
  end
end
