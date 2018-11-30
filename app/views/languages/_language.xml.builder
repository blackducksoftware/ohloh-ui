xml.language do
  xml.id language.id
  xml.name language.name
  xml.nice_name language.nice_name
  xml.category %w[code markup build][language.category]
  xml.code language.code
  xml.comments language.comments
  xml.blanks language.blanks
  xml.comment_ratio language.avg_percent_comments
  xml.projects language.projects
  xml.contributors language.contributors
  xml.commits language.commits
end
