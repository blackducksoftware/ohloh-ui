module OhDelegator
  class Base < SimpleDelegator
    extend ParentScope

    def initialize(delegable)
      super

      define_singleton_method(delegable.class.name.underscore) do
        @delegable ||= delegable
      end
    end
  end
end
