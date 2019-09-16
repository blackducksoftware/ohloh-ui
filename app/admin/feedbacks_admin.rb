# frozen_string_literal: true

ActiveAdmin.register Feedback do
  config.sort_order = ''
  actions :index, :dashboard, :project
  filter :project_name, as: :string, label: 'Project Name'

  index do
    column :logo, max_width: '100px' do |feedback|
      feedback.project.decorate.icon(:med)
    end
    column :project_id, sortable: false do |feedback|
      feedback.project.name
    end
    column :count do |feedback|
      Feedback.where(project_id: feedback.project_id).count
    end
    column :interested do |feedback|
      Feedback.interested(feedback.project_id)
    end
    column :rating, sortable: false do |feedback|
      render 'rating', scale: Feedback.rating_scale(feedback.project_id)
    end
  end

  controller do
    def scoped_collection
      Feedback.select('count(*) as count, project_id').where.not(project_id: nil)
              .group(:project_id).reorder('count desc')
    end
  end
end
