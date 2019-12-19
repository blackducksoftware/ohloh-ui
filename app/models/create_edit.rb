# frozen_string_literal: true

class CreateEdit < Edit
  def do_undo
    target.update!(deleted: true)
  end

  def do_redo
    target.update!(deleted: false)
  end

  def allow_undo?
    target.respond_to?(:allow_undo?) ? target.allow_undo?(key.to_s.to_sym) : true
  end

  def allow_redo?
    target.respond_to?(:allow_redo?) ? target.allow_redo?(key.to_s.to_sym) : true
  end
end
