# frozen_string_literal: true

class Route
  include InstanceCounter

  attr_reader :intermediate_station, :final, :initial

  def initialize(initial, final)
    @initial = initial
    @final = final
    @intermediate_station = []
    validate!
    register_instance
  end

  def valid?
    validate!
    true
  rescue StandardError
    false
  end

  def add_station(station)
    @intermediate_station << station
  end

  def delete_station(name)
    @intermediate_station.delete(name)
  end

  # rubocop:disable all

  def stations
    stations = [@initial, *@intermediate_station, @final]
  end

  # rubocop:anable all

  private

  def validate!
    raise 'Route should have initial station' if initial.nil?
    raise 'Route should have final station' if final.nil?
  end
end
