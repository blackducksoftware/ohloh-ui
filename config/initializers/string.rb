class String
  def fix_encoding_if_invalid!
    unless self.valid_encoding?
      self.encode!('utf-8', 'binary', invalid: :replace, undef: :replace)
    end
    self
  end
end
