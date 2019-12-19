# frozen_string_literal: true

class ActivationCode
  def self.generate
    SecureRandom.hex(20)
  end
end
