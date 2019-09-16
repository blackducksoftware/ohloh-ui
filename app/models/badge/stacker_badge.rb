# frozen_string_literal: true

class StackerBadge < Badge
  def eligibility_count
    @eligibility_count ||= vars[:stacks_count]
    stacks = Stack.arel_table
    @eligibility_count ||= Stack.where(stacks[:project_count].gt(0))
                                .where(deleted_at: nil, account_id: account.id).count
  end

  def short_desc
    I18n.t('badges.stacker.short_desc')
  end

  def level_limits
    [1, 2, 3, 4, 5]
  end

  def position
    40
  end
end
