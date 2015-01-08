class CreateEdit < Edit
  def do_undo
    target.update_attributes!(deleted: true)
  end

  def do_redo
    target.update_attributes!(deleted: false)
  end
end
