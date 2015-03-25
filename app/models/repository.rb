class Repository < ActiveRecord::Base
  has_many :enlistments, -> { not_deleted }
  has_many :projects, through: :enlistments

  scope :matching, ->(match) { Repository.forge_match_search(match) }

  attr_accessor :forge_match

  class << self
    def forge_match_search(m)
      wheres = where(forge_id: m.forge.id).where(['lower(repositories.name_at_forge) = ?', m.name_at_forge.downcase])
      if m.owner_at_forge
        wheres.where(['lower(repositories.owner_at_forge) = ?', m.owner_at_forge.downcase])
      else
        wheres.where(owner_at_forge: nil)
      end
    end
  end
end
