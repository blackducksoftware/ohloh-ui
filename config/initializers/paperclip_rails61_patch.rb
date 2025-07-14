# frozen_string_literal: true

# Monkey patch for Paperclip to work with Rails 6.1
# This is a temporary fix until the application is migrated from Paperclip to Active Storage
module ActiveModel
  class Errors
    # Store original add method
    alias original_add add

    # Override add method to handle both old and new argument formats
    def add(attribute, message = :invalid, options = {})
      if message.is_a?(Symbol) && options.is_a?(Hash) && !options.empty?
        original_add(attribute, message, **options)
      else
        original_add(attribute, message)
      end
    end
  end
end
