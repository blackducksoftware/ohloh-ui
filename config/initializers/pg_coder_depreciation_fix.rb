# frozen_string_literal: true

# This initializer addresses the deprecation warning:
# PG::Coder.new(hash) is deprecated. Please use keyword arguments instead!
#
# The warning comes from ActiveRecord's PostgreSQL adapter which instantiates
# PG::Coder with a hash rather than keyword arguments. This monkey patch
# allows both styles of initialization.

if defined?(PG::Coder)
  PG::Coder.singleton_class.class_eval do
    alias_method :original_new, :new

    def new(*args, **kwargs)
      if args.length == 1 && args[0].is_a?(Hash) && kwargs.empty?
        # Convert hash argument to keyword arguments
        original_new(**args[0])
      else
        original_new(*args, **kwargs)
      end
    end
  end
end
