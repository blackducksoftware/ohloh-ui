# frozen_string_literal: true

# rubocop:disable HasManyOrHasOneDependent

class Forge::Base < ActiveRecord::Base
  self.table_name = 'forges'
  has_many :repositories, foreign_key: 'forge_id'
  has_many :projects, foreign_key: 'forge_id'
end

# rubocop:enable HasManyOrHasOneDependent
