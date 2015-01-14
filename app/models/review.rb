class Review < ActiveRecord::Base
  belongs_to :account
  belongs_to :project
  has_many :helpfuls

  scope :for_project, ->(project) { where(project_id: project.id) }
  scope :top, ->(limit = 2) { three_quarters_helpful_arel.order_by_helpfulness_arel.limit(limit) }

  class << self
    def three_quarters_helpful_arel
      where Review.send(:sanitize_sql, "(#{pos_or_neg_sql(true)}) * 3 >= (#{pos_or_neg_sql(false)})")
    end

    def order_by_helpfulness_arel
      order_by = "(#{pos_or_neg_sql(true)}) - (#{pos_or_neg_sql(false)}) DESC, \"reviews\".\"created_at\" ASC"
      order Review.send(:sanitize_sql, order_by)
    end

    private

    def pos_or_neg_sql(pos)
      helpfuls = Helpful.arel_table
      reviews = Review.arel_table
      sql = Helpful.select('count(*)').where(helpfuls[:review_id].eq(reviews[:id]))
      sql = pos ? sql.positive : sql.negative
      sql.to_sql
    end
  end
end
