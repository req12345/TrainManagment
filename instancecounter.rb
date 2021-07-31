# frozen_string_literal: true

module InstanceCounter
  class << self
    def included(base)
      base.extend ClassMethods
    end
  end

  private

  def register_instance
    self.class.increase_instance_counter
  end

  module ClassMethods
    def instances_counter
      @counter || 0
    end

    def increase_instance_counter
      @counter = instances_counter + 1
    end
  end
end
