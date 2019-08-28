# frozen_string_literal: true

ActiveAdmin.register AnalyzeJob do
  belongs_to :project, finder: :find_by_vanity_url!, optional: true
  menu false
end
