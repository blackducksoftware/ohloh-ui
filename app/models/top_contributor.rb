class TopContributor < Contribution
  self.table_name = 'top_contributors_view'
  self.primary_key = :id
end
