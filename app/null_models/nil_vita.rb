# frozen_string_literal: true

class NilVita < NullObject
  def vita_fact
    NilVitaFact.new
  end

  def vita_language_facts
    VitaLanguageFact.none
  end

  def id
    0
  end
end
