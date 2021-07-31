module Validation
  def self.included(base)
    base.extend(ClassMethods)
    base.send :include, InstanceMethods
  end

  FORMAT_NUMBER = /\A[а-я \w \d]{3}-*[а-я \w \d]{2}\Z/i.freeze

  class ValidationError < StandardError
  end

# rubocop:disable all

  module ClassMethods
    def validate(*attributes)
      @validations ||= []

      name = attributes[0]
      value = instance_variable_get("@#{name}")

      validator = attributes[1]
      validation = attributes[2]

      @validations << {
        name: name,
        validator: validator,
        validation: validation
      }
    end
  end

# rubocop:anable all

  module InstanceMethods
    def validate!
      validations = self.class.instance_variable_get('@validations')
      errors = []

      validations.each do |validation|
        value = instance_variable_get("@#{validation[:name]}")
        error = send(validation[:validator], validation[:name], value, validation[:validation])

        errors << error if error
      end

      raise ValidationError, errors unless errors.empty?
      true
    end

    private

    def type(attr, value, type)
      return "#{attr}: Ожидается тип #{type}" unless value.is_a?(type)
    end

    def presence(attr, value, _validation)
      return { attr: attr, error: 'Не может быть пустым' } if value.nil?
    end

    def format(attr, value, validation)
      return "#{attr}: не соответствует формату #{FORMAT_NUMBER.to_s}" unless !!"#{value}".match?(validation)
    end

    def name_length(attr, value, _validation)
      return "#{attr}: должен быть как минимум 2 символа" if value.length < 2
    end

    def valid?
      validate!
      true
    rescue ValidationError
      false
    end
  end
end

class Test
  include Validation

  validate :name, :presence
  validate :age, :type, Integer
  validate :number, :format, FORMAT_NUMBER
  attr_accessor :name, :age, :number
end
