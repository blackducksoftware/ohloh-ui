# frozen_string_literal: true

module EmailObfuscation
  def obfuscate_email(email = '')
    email.to_s
         .gsub(/\b([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-]+.[a-zA-Z]{2,4})\b/) { $1[0..-($1.length / 2 + 1)] + '...@' + $2 }
  end
end
