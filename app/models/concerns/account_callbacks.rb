# frozen_string_literal: true

module AccountCallbacks
  extend ActiveSupport::Concern

  included do
    before_validation Account::Hooks.new
    before_validation Account::Encrypter.new
    before_save Account::Encrypter.new
    before_destroy Account::Hooks.new
    after_create Account::Hooks.new
    after_update Account::Hooks.new
    after_destroy Account::Hooks.new
    after_save Account::Hooks.new
  end
end
