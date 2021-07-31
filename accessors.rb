module Accessors
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def attr_accessor_with_history(*attr)
      attr.each do |attr|
        var_name = "@#{attr}".to_sym

        define_method(attr) { instance_variable_get(var_name) }

        define_method("#{attr}_history") { instance_variable_get("@#{attr}_history") }

        define_method("#{attr}=".to_sym) do |value|
          instance_variable_set(var_name, value)
          history = instance_variable_get("@#{attr}_history") || []
          instance_variable_set("@#{attr}_history", history << value)
        end
      end
    end

    def strong_attr_accessor(attr_name, attr_class)
      define_method(attr_name) { instance_variable_get("@#{attr_name}".to_sym) }

      define_method("#{attr_name}=".to_sym) do |value|
        raise TypeError, "Type should be #{attr_class}" unless value.is_a?(attr_class)

        instance_variable_set("@#{attr_name}", value)
      end
    end
  end
end

class Test
  include Accessors

  attr_accessor_with_history :a, :b

  strong_attr_accessor :c, Integer
  strong_attr_accessor :d, String
end
