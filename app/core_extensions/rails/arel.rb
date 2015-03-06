class Arel::Table
  def coalesce_and_sum(column, value)
    coalesce_result = Arel::Nodes::NamedFunction.new('COALESCE', [self[column], value])
    Arel::Nodes::NamedFunction.new('SUM', [coalesce_result], column.to_s)
  end
end
