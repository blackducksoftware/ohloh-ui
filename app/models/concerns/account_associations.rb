# frozen_string_literal: true

module AccountAssociations
  extend ActiveSupport::Concern

  included do
    belongs_to :markup, foreign_key: :about_markup_id, autosave: true, class_name: 'Markup'
    belongs_to :best_account_analysis, foreign_key: 'best_vita_id', class_name: 'AccountAnalysis'
    belongs_to :organization
    has_one :person
    has_many :api_keys
    has_many :actions
    has_many :kudos
    has_many :sent_kudos, class_name: 'Kudo', foreign_key: :sender_id
    has_many :topics
    has_many :ratings
    has_many :reviews
    has_many :posts
    has_many :invites, class_name: 'Invite', foreign_key: 'invitor_id'
    has_many :manages, -> { where.not(approved_by: nil).where(deleted_by: nil, deleted_at: nil) }
    has_many :all_manages, -> { where(deleted_by: nil, deleted_at: nil) }, class_name: 'Manage'
    has_many :edits
    has_many :verifications
    has_many :account_analysis_jobs, dependent: :destroy
    has_one :manual_verification
    has_one :github_verification
    has_one :firebase_verification
    has_one :reverification_tracker, dependent: :destroy
  end
end
