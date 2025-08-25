# frozen_string_literal: true

class Badge::TaxonomistBadge < Badge
  def eligibility_count
    @eligibility_count ||= vars[:tags_count]
    @eligibility_count ||= Edit.where(target_type: 'Project', key: 'tag_list', account_id: account.id).count
  end

  def name
    'TAX(I)onomist'
  end

  def short_desc
    I18n.t('badges.taxonomist.short_desc')
  end

  def level_limits
    [1, 4, 15, 25, 55, 100, 200, 400, 600, 1000, 5000, 10_000]
  end

  def position
    70
  end
end
