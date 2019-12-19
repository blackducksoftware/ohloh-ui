# frozen_string_literal: true

ActiveAdmin.register SlocJob do
  belongs_to :project, finder: :find_by_vanity_url!, optional: true
  actions :index, :show, :destroy, :edit
  menu false
end
