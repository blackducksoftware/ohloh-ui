# frozen_string_literal: true

# Add Ransack 4.0+ compatibility to external models and models without direct access
# This is required because we can't directly modify these models

# rubocop:disable Metrics/BlockLength
Rails.application.config.to_prepare do
  # Add compatibility for JobStatus
  JobStatus.class_eval do
    def self.ransackable_attributes(_auth_object = nil)
      # Ensure all possible attributes are included to avoid filter issues
      column_names + %w[id name description created_at updated_at incomplete failed]
    end

    def self.ransackable_associations(_auth_object = nil)
      %w[jobs organization_analysis_jobs]
    end
  end

  # Add compatibility for Worker model
  Worker.class_eval do
    def self.ransackable_attributes(_auth_object = nil)
      %w[allow_deny blocked_types enable_profiling hostname id load_average queue_name
         used_percent created_at updated_at]
    end

    def self.ransackable_associations(_auth_object = nil)
      ['jobs']
    end
  end

  Doorkeeper::Application.class_eval do
    def self.ransackable_attributes(_auth_object = nil)
      %w[confidential created_at id name redirect_uri scopes secret uid updated_at]
    end

    def self.ransackable_associations(_auth_object = nil)
      %w[access_grants access_tokens]
    end
  end

  # Add compatibility to any other Doorkeeper models used in ActiveAdmin
  Doorkeeper::AccessToken.class_eval do
    def self.ransackable_attributes(_auth_object = nil)
      %w[created_at id resource_owner_id scopes token updated_at]
    end

    def self.ransackable_associations(_auth_object = nil)
      ['application']
    end
  end

  Doorkeeper::AccessGrant.class_eval do
    def self.ransackable_attributes(_auth_object = nil)
      %w[code created_at expires_in id redirect_uri resource_owner_id revoked_at scopes
         updated_at]
    end

    def self.ransackable_associations(_auth_object = nil)
      ['application']
    end
  end
  # rubocop:enable Metrics/BlockLength
end
