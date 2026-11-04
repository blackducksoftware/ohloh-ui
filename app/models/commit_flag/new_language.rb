# frozen_string_literal: true

class CommitFlag::NewLanguage < CommitFlag
  def language
    return nil unless data && data[:language_id]

    Language.find(data[:language_id].to_i)
  end

  def language_id=(language_id)
    self.data ||= {}
    data[:language_id] = language_id
  end
end
