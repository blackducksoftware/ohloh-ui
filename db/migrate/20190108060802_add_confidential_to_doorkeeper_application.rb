# frozen_string_literal: true

class AddConfidentialToDoorkeeperApplication < ActiveRecord::Migration[4.2]
  def change
    add_column(
      :oauth_applications,
      :confidential,
      :boolean,
      null: false,
      default: true # maintaining backwards compatibility: require secrets
    )
  end
end
