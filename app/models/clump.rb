# frozen_string_literal: true

class Clump < ActiveRecord::Base
  belongs_to :code_set
  belongs_to :slave

  def path
    slave.path_from_code_set_id(code_set_id)
  end
end
