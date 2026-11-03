# frozen_string_literal: true

module PasswordGenerator
  UPPERCASE = ('A'..'Z').to_a.freeze
  LOWERCASE = ('a'..'z').to_a.freeze
  DIGITS = ('0'..'9').to_a.freeze
  SPECIALS = %w[! @ # $ % ^ & *].freeze
  POOL = (LOWERCASE + UPPERCASE + DIGITS + SPECIALS).freeze

  def self.generate(length = 12)
    required_chars = [UPPERCASE.sample, LOWERCASE.sample, DIGITS.sample, SPECIALS.sample]
    remaining = [length - 4, 0].max
    (required_chars + POOL.sample(remaining)).shuffle.join
  end
end
