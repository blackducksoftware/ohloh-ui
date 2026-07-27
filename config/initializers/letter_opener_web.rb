# frozen_string_literal: true

Rails.application.config.to_prepare do
  next unless defined?(LetterOpenerWeb::LettersController)

  LetterOpenerWeb::LettersController.class_eval do
    before_action :check_access
    private
    def check_access
      redirect_to main_app.new_session_path if request.env[:clearance].current_user.nil?
    end
  end
end
