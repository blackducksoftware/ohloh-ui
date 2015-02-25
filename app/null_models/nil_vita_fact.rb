class NilVitaFact < NullObject
  def first_checkin
    nil
  end

  def last_checkin
    nil
  end

  def commits
    0
  end

  def commits_by_language
    []
  end

  def commits_by_project
    []
  end
end
