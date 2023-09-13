# frozen_string_literal: true

json.id project.id
json.name project.name
json.description project.description
json.licenses project.licenses.map(&:name).uniq.compact.join(', ')
json.vulnerability_score project.project_vulnerability_report&.vulnerability_score&.to_f
