class Language < ActiveRecord::Base
  class << self
    def new_languages_for_project(project, days)
      new_languages_collection = project.commit_flags.new_languages.where(['commit_flags.time > ?', days]).to_a
      new_languages_collection.sort_by(&:time).group_by(&:data)
    end
  end

  def total
    code.to_i + comments.to_i + blanks.to_i
  end
end
