class RepoPersonBadge < Badge
  def eligibility_count
    @count ||= vars[:repo_edit_count]
    @count ||= Edit.where(target_type: 'Enlistment', key: nil, account_id: account.id).count
  end

  def name
    'Repo Man/Woman'
  end

  def short_desc
    'edits project repositories'
  end

  def level_limits
    [1, 5, 15, 35, 70, 110, 200, 500, 1000, 2000, 4000, 10_000]
  end

  def position
    20
  end
end
