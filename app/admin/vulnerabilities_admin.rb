# frozen_string_literal: true

ActiveAdmin.register Vulnerability do
  filter :cve_id
  filter :generated_on
  filter :published_on

  belongs_to :release

  actions :index, :show

  index do
    column :id
    column :cve_id
    column :generated_on
    column :published_on
    column :severity
    column :score
    column :created_at
    column :updated_at
    actions
  end
end
