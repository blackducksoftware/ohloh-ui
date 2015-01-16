module OhDelegator
  module ParentScope
    def parent_scope(&block)
      delegable.class_exec(&block)
    end

    private

    def delegable
      @delegable ||= delegable_name.constantize
    end

    def delegable_name
      @delegable_name ||= name.slice(/^[^:]+/)
    end
  end
end
