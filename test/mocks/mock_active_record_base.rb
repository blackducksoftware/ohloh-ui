require "#{Rails.root}/app/models/acts_as_editable/acts_as_editable.rb"

class MockActiveRecordBase
  def self.after_creates
    @after_creates || []
  end

  def self.before_saves
    @before_saves || []
  end

  def self.after_saves
    @after_saves || []
  end

  def self.after_create(method)
    @after_creates = after_creates << method
  end

  def self.before_save(method)
    @before_saves = before_saves << method
  end

  def self.after_save(method)
    @after_saves = after_saves << method
  end

  def save
    save!
    true
  rescue
    false
  end

  def save!
    self.class.before_saves.each { |m| send(m) }
    self.class.after_saves.each { |m| send(m) }
  end

  def self.create(*_)
    new.save!
    after_creates.each { |m| send(m) }
  rescue
    false
  end

  def self.create!(*_)
    new.save!
    after_creates.each { |m| send(m) }
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
