# frozen_string_literal: true

class TrainCargo < Train
  def initialize(number, *wagons)
    @type = 'cargo'
    super
  end
end
