class Review < ActiveRecord::Base
  belongs_to :account
  belongs_to :project
  has_many :helpfuls, dependent: :destroy

  validates :title, presence: true
  validates :account_id, presence: true
  validates :comment, presence: true
  validates :comment, length: { in: 1..5000 }, allow_blank: true

  before_save do |review|
    sanitizer       = Rails::Html::FullSanitizer.new
    review.title    = sanitizer.sanitize(review.title)
    review.comment  = sanitizer.sanitize(review.comment)
  end

  scope :by_account, ->(account) { where(account_id: account.id) }
  scope :for_project, ->(project) { where(project_id: project.id) }
  scope :top, ->(limit = 2) { three_quarters_helpful_arel.order_by_helpfulness_arel.limit(limit) }
  scope :sort_by, lambda { |key = :helpful|
    {
      'helpful' => order_by_helpfulness_arel,
      'highest_rated' => order(ratings_sql('DESC')).order(created_at: :desc),
      'lowest_rated' => order(ratings_sql).order(:created_at),
      'project' => includes(:project).order('projects.name'),
      'recently_added' => order(created_at: :desc),
      'author' => joins(:account).order('accounts.login').order(created_at: :desc)
    }.fetch(key, order_by_helpfulness_arel)
  }

  filterable_by ['comment', 'title', 'accounts.login']

  # rubocop:disable Style/MultilineIfModifier
  scope :find_by_comment_or_title_or_accounts_login, lambda { |query|
    includes(:account)
      .references(:all)
      .filter_by(query) if query
  }
  # rubocop:enable Style/MultilineIfModifier

  def score
    return 0 unless project_id && account_id

    Rating.find_by(project_id: project_id, account_id: account_id).try(:score).to_i
  end

  def helpful_to_account?(account)
    helpfuls.for_account(account).positive.exists?
  end

  def not_helpful_to_account?(account)
    helpfuls.for_account(account).negative.exists?
  end

  class << self
    def three_quarters_helpful_arel
      where sanitize_sql("(#{pos_or_neg_sql(true)}) * 3 >= (#{pos_or_neg_sql(false)})")
    end

    def order_by_helpfulness_arel
      positive_sql = pos_or_neg_sql(true)
      negative_sql = pos_or_neg_sql(false)
      order_by = "(#{positive_sql}) - (#{negative_sql}) DESC, (#{positive_sql}) DESC"
      order(sanitize_sql(order_by)).order(:created_at)
    end

    private

    def ratings_sql(sort_order = 'ASC')
      sql = Rating.where('ratings.account_id = reviews.account_id AND ratings.project_id = reviews.project_id')
                  .select(:score).to_sql
      sql = "( #{sql} ) #{sort_order.eql?('DESC') ? ' DESC NULLS LAST' : ' ASC NULLS FIRST'}"
      sanitize_sql(sql)
    end

    def pos_or_neg_sql(pos)
      helpfuls = Helpful.arel_table
      reviews = Review.arel_table
      sql = Helpful.select('count(*)').where(helpfuls[:review_id].eq(reviews[:id]))
      sql = pos ? sql.positive : sql.negative
      sql.to_sql
    end
  end
end
