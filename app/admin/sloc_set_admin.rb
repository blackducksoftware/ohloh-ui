# frozen_string_literal: true

ActiveAdmin.register SlocSet do
  menu false
  belongs_to :code_set, optional: true
  actions :index, :show

  filter :updated_on
  filter :as_of
end
