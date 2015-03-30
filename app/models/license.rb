class License < ActiveRecord::Base
  scope :from_param, ->(id) { where(name: id) }

  acts_as_editable editable_attributes: [:name, :nice_name, :abbreviation, :description, :url],
                   merge_within: 30.minutes
  acts_as_protected

  fix_string_column_encodings!

  def to_param
    name
  end

  def allow_undo_to_nil?(key)
    ![:name, :nice_name].include?(key)
  end

  def allow_edit?
    editor_account && (Account::Access.new(editor_account).admin? || !locked)
  end

  def short_name
    abbreviation.blank? ? nice_name : abbreviation
  end

  class << self
    def autocomplete(term)
      License.select([:nice_name, :id]).where(['lower(nice_name) LIKE ?', "#{term.downcase}%"]).limit(10)
    end
  end
end
