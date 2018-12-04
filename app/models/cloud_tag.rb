class CloudTag
  TAGS_LIST = YAML.load_file(Rails.root.join('config', 'tags_list.yml'))

  class << self
    def list
      index = TAGS_LIST.length - Time.current.day
      TAGS_LIST[index].sort_by { |a| a[0] }
    end
  end
end
