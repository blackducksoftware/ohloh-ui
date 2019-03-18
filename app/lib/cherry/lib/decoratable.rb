module Cherry
  module Decoratable
    def decorate
      decorator_name = "#{self.class.name}Decorator"
      @decorate ||= decorator_name.constantize.new(self)
    end
  end
end
