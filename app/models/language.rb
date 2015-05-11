class Language < ActiveRecord::Base
  ALL_LANGUAGES = ['All Languages', '']

  class << self
    def new_languages_for_project(project, days)
      new_languages_collection = project.commit_flags.new_languages.where(['commit_flags.time > ?', days]).to_a
      new_languages_collection.sort_by(&:time).group_by(&:data)
    end

    def map
      Language.order(arel_table[:nice_name].lower).each_with_object([]) do |language, array|
        array << [language.nice_name, language.name]
      end.unshift(ALL_LANGUAGES)
    end
  end

  def total
    code.to_i + comments.to_i + blanks.to_i
  end
end
