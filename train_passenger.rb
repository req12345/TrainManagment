# frozen_string_literal: true

class TrainPassenger < Train
  def initialize(number, *wagons)
    @type = 'passanger'
    super
  end
end
