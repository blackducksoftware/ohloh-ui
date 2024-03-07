# frozen_string_literal: true

class NilCodeLocation < NullObject
  blank_methods :url, :nice_url
  nil_methods :branch, :username, :password, :cl_update_event_time, :best_code_set

  def scm_type
    :git
  end

  def scm_name_in_english
    :Git
  end

  def do_not_fetch
    true
  end
end
