# frozen_string_literal: true

class NilCodeLocation < NullObject
  blank_methods :url, :nice_url
  nil_methods :branch

  def scm_type
    :git
  end
end
