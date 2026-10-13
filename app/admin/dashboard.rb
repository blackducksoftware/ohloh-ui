# frozen_string_literal: true

ActiveAdmin.register_page 'OH Admin' do
  menu priority: 2, label: 'OH Admin'

  controller do
    def index
      redirect_to oh_admin_root_path
    end
  end
end

