module OhDelegator
  module Delegable
    def oh_delegators(*attributes)
      attributes.each do |attribute|
        # Read the delegator class alongwith the delegable.
        klass = "#{ name }::#{ attribute.to_s.classify }".constantize

        define_method attribute do
          instance_variable_name = "@#{ attribute }"
          instance_variable = instance_variable_get(instance_variable_name)

          return instance_variable if instance_variable

          instance_variable_set(instance_variable_name, klass.new(self))
        end
      end
    end
  end
end
