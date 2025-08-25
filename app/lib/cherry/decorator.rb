# frozen_string_literal: true

module Cherry
  class Decorator
    attr_reader :object

    def initialize(object, options = {})
      @object = object
      @context = options.fetch(:context, {})
      define_accessor_by_name(object)
    end

    def h
      Rails.application.routes.url_helpers
    end

    private

    def define_accessor_by_name(object)
      object_name = object.class.name.underscore
      define_singleton_method(object_name) { object }
    end
  end
end
