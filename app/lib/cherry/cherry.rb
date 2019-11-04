# frozen_string_literal: true

require_relative 'lib/decorator'
require_relative 'lib/decoratable'

# == Usage
#
# === Cherry adds a +decorate+ method to all +ActiveRecord::Base+ sub classes.
#
#   class User < ActiveRecord::Base
#     def some_logic
#     end
#   end
#
#   class UserDecorator < Cherry::Decorator
#     # The decorator can access the decoratee object by its inferred name.
#     delegate :some_logic, to: :user
#
#     def view_logic
#       some_logic
#     end
#   end
#
#   User.first.decorate.view_logic
#
# === Cherry also supports standalone decorators which can associate with any model.
#
#   class GenericDecorator < Cherry::Decorator
#     # Delegable object is also available via a accessor named +object+.
#     delegate :some_logic, to: :object
#
#     def view_logic
#       some_logic
#     end
#   end
#
#   GenericDecorator.new(@user).view_logic
#
# === Include the +Cherry::Decoratable+ to decorate any model.
#
#   class CustomModel
#     include Cherry::Decoratable
#   end
#
#   CustomModel.new.decorate   # will initialize a +CustomModelDecorator+.
#
# == Additional arguments
#
# Cherry exposes a +@context+ variable for any additional data that needs to be passed on to the delegator.
#
#   class User < ActiveRecord::Base
#   end
#
#   class UserDecorator < Cherry::Decorator
#     def view_logic
#       @context[:scope]
#     end
#   end
#
#   UserDecorator.new(@user, context: { scope: :full }).view_logic   #=> 'full'
#
module Cherry
end

ActiveRecord::Base.class_eval do
  include Cherry::Decoratable
end
