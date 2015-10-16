class CreateEdit < Edit
  def do_undo
    target.update_attributes!(deleted: true)
  end

  def do_redo
    target.update_attributes!(deleted: false)
  end

  def allow_undo?
    true
  end

  def allow_redo?
    target.respond_to?(:allow_redo?) ? target.allow_redo?(key.to_s.to_sym) : true
  end
end
