class Repository < ActiveRecord::Base
  has_many :enlistments, -> { not_deleted }
  has_many :projects, through: :enlistments

  scope :matching, ->(match) { Repository.forge_match_search(match) }

  attr_accessor :forge_match

  class << self
    def forge_match_search(match)
      wheres = where(forge_id: match.forge.id).where(['lower(name_at_forge) = ?', match.name_at_forge.downcase])
      if match.owner_at_forge
        wheres.where(['lower(owner_at_forge) = ?', match.owner_at_forge.downcase])
      else
        wheres.where(owner_at_forge: nil)
      end
    end
  end
end
