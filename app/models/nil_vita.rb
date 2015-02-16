class NilVita
  def vita_fact
    NilVitaFact.new
  end

  def vita_language_facts
    VitaLanguageFact.none
  end

  def nil?
    true
  end
end
