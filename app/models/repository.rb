class Repository < ActiveRecord::Base
  belongs_to :forge, class_name: 'Forge::Base'
  has_many :code_locations

  scope :matching, ->(match) { Repository.forge_match_search(match) }

  validates :url, presence: true

  attr_accessor :forge_match

  def name_in_english
    source_scm.english_name
  end

  def source_scm
    @source_scm ||= source_scm_class.new(attributes.symbolize_keys.merge(public_urls_only: !ENV['INTEGRATION_TEST']))
  end

  def source_scm_class
    OhlohScm::Adapters::AbstractAdapter
  end

  class << self
    def get_compatible_class(_url)
      self
    end

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
