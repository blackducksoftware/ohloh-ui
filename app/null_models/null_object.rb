# frozen_string_literal: true

class NullObject
  def nil?
    true
  end

  def present?
    false
  end

  def blank?
    true
  end

  class << self
    def nought_methods(*args)
      args.each do |method_name|
        define_method method_name, -> { 0 }
      end
    end

    def blank_methods(*args)
      args.each do |method_name|
        define_method method_name, -> { '' }
      end
    end

    def nil_methods(*args)
      args.each do |method_name|
        define_method method_name, -> {}
      end
    end

    def empty_methods(*args)
      args.each do |method_name|
        define_method method_name, -> { [] }
      end
    end
  end
end
