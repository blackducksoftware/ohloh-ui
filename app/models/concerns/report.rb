# frozen_string_literal: true

module Report
  extend ActiveSupport::Concern

  def contributor_history(start_date, end_date)
    sql = <<-INLINE_SQL
    SELECT M.month AS month ,COALESCE( COUNT(DISTINCT(AF.name_id)),0) AS contributors
    FROM all_months M LEFT OUTER JOIN activity_facts AF ON M.month = AF.month
    AND AF.analysis_id = '#{id}' WHERE M.month >= '#{start_date}'
    AND M.month <= '#{end_date}' GROUP BY  M.month ORDER BY  M.month
    INLINE_SQL
    self.class.connection.select_all(sql)
  end

  def code_total_history(start_date, end_date)
    sql = <<-INLINE_SQL
    SELECT M.month AS month, COALESCE( SUM(AF.code_added - AF.code_removed), 0) AS code_total
    ,COALESCE( SUM(AF.comments_added - AF.comments_removed), 0) AS comments_total
    ,COALESCE( SUM(AF.blanks_added - AF.blanks_removed), 0) AS blanks_total
    FROM all_months M LEFT OUTER JOIN activity_facts AF ON AF.month <= M.month
    AND AF.analysis_id = '#{id}' AND AF.on_trunk WHERE M.month >= date_trunc('month', TIMESTAMP '#{start_date}')
    AND M.month <= date_trunc('month', TIMESTAMP '#{end_date}') GROUP BY  M.month ORDER BY  M.month
    INLINE_SQL
    self.class.connection.select_all(sql)
  end

  def commit_history(start_date, end_date)
    sql = <<-INLINE_SQL
    SELECT month, COALESCE(count,0) AS commits FROM all_months M LEFT OUTER JOIN (SELECT COUNT(*)
    AS count, date_trunc('month', C.time) AS this_month FROM analysis_sloc_sets ASS INNER JOIN sloc_sets SS
    ON SS.id = ASS.sloc_set_id INNER JOIN code_sets CS ON CS.id = SS.code_set_id INNER JOIN commits C
    ON CS.id = C.code_set_id AND C.position <= ASS.as_of INNER JOIN analysis_aliases K ON C.name_id = K.commit_name_id
    AND K.analysis_id = '#{id}' WHERE ASS.analysis_id = '#{id}' GROUP BY this_month ORDER BY this_month ASC) AS counts
    ON counts.this_month=M.month WHERE M.month >= '#{start_date}' AND M.month <= '#{end_date}' ORDER BY M.month;
    INLINE_SQL
    self.class.connection.select_all(sql)
  end
end
