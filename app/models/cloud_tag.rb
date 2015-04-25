class CloudTag
  TAGS_LIST = YAML.load File.read("#{Rails.root}/config/tags_list.yml")

  class << self
    def list
      index = TAGS_LIST.length - Time.now.day
      TAGS_LIST[index].sort { |a, b| a[0] <=> b[0] }
    end
  end
end
