class ActivationCode
  def self.generate
    Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by { rand }.join)
  end
end
