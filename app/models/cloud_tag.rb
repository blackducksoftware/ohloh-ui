class CloudTag
  TAGS = YAML.load File.read("#{Rails.root}/config/tags_list.yml")

  class << self
    def list
      index = TAGS.length - Time.now.day
      TAGS[index].sort { |a, b| a[0] <=> b[0] }
    end
  end

end
