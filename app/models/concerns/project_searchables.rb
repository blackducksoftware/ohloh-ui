module ProjectSearchables
  extend ActiveSupport::Concern

  included do
    def searchable_vector
      {
        a: split_name_if_camecase_present,
        b: tag_list,
        c: collect_tags_licenses_and_language,
        d: description
      }
    end

    def searchable_factor
      max_user_count = Project.not_deleted.maximum(:user_count)
      return 0.0 if user_count.zero? || max_user_count.to_i.zero?

      Math.log10(user_count * 2) / Math.log10(max_user_count * 2)
    end

    private

    def collect_tags_licenses_and_language
      tag_list + main_language.to_s +
        licenses.map(&:vanity_url).uniq.compact.join(' ')
    end

    def split_name_if_camecase_present
      "#{(name.split + name.titleize.split).uniq.join(' ')} #{vanity_url}"
    end
  end
end
