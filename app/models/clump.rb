# frozen_string_literal: true

class Clump < ApplicationRecord
  belongs_to :code_set, optional: true
  belongs_to :slave, optional: true

  def path
    return nil unless slave

    slave.path_from_code_set_id(code_set_id)
  end
end
