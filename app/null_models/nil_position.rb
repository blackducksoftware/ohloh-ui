class NilPosition < NullObject
  attr_reader :title

  def active?
    false
  end
end
