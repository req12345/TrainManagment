# frozen_string_literal: true

class Wagon
  include Manufacturer

  attr_reader :type, :number

  def initialize(number)
    @number = number
  end
end
