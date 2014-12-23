class Account < ActiveRecord::Base
  DEFAULT_LEVEL = 0
  ADMIN_LEVEL   = 10
  DISABLE_LEVEL = -10
  SPAMMER_LEVEL = -20

  has_many :api_keys
  has_many :manages, -> { where.not(approved_by: nil).where(deleted_by: nil, deleted_at: nil) }
  has_many :projects, -> { where(deleted: false) }, through: :manages, source: :target, source_type: 'Project'
  has_many :stacks, -> { order 'stacks.title' }
  has_many :actions
  has_one :person

  scope :from_param, ->(param) { where(arel_table[:login].eq(param).or(arel_table[:id].eq(param))) }

  fix_string_column_encodings!

  def admin?
    level == ADMIN_LEVEL
  end

  def disabled?
    level < DEFAULT_LEVEL
  end

  def activated?
    activated_at != nil
  end

  def default_stack
    stacks << Stack.new unless @cached_default_stack || stacks.count > 0
    @cached_default_stack ||= stacks[0]
  end

  def to_param
    login_urlable? && login || id.to_s
  end

  def login_urlable?
    login =~ /^[a-zA-Z][\w-]{2,30}$/
  end

  class << self
    def hamster
      from_param('ohloh_slave').first!
    end
  end
end
