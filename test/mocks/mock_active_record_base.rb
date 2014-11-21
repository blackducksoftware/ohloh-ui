require "#{Rails.root}/app/models/acts_as_editable/acts_as_editable.rb"

class MockActiveRecordBase
  def self.before_saves
    @before_saves || []
  end

  def self.before_save(method)
    @before_saves = before_saves << method
  end

  def save
    save!
    true
  rescue
    false
  end

  def save!
    self.class.before_saves.each { |m| send(m) }
  end

  def create(*_)
    save
  end

  def create!(*_)
    save!
  end

  def update
    save
  end

  def update!
    save!
  end

  def update_attributes(*_)
    save
  end

  def update_attributes!(*_)
    save!
  end
end

MockActiveRecordBase.send :include, ActsAsEditable
