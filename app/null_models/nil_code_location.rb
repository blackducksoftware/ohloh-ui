# frozen_string_literal: true

class NilCodeLocation < NullObject
  blank_methods :url, :nice_url
  nil_methods :branch, :username, :password

  def scm_type
    :git
  end

  def do_not_fetch
    true
  end
end
