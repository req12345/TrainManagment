# frozen_string_literal: true

class Train
  include Manufacturer
  include InstanceCounter
  include Validation
  include Accessors

  FORMAT_NUMBER = /\A[а-я \w \d]{3}-*[а-я \w \d]{2}\Z/i.freeze

  @@trains = []

  attr_accessor :speed, :number
  attr_reader :wagons, :route, :station, :type, :wagon
  validate :number, :presence
  validate :number, :format, FORMAT_NUMBER

  def initialize(number, *wagons)
    @number = number
    @wagons = wagons
    @speed = 0
    @route = nil
    @station = nil
    @@trains << self
    validate!
    register_instance
  end

  def trains_wagons(&block)
    @wagons.each(&block)
  end

  def valid?
    validate!
    true
  rescue StandardError
    false
  end

  def self.find(number)
    @@trains.select { |t| t.number == number }.first
  end

  def stop
    @speed = 0
  end

  def attach_wagon(wagon)
    return if speed != 0 && wagon.type != type

    @wagons << wagon
  end

  def detach_wagon(wagon)
    @wagons.delete(wagon) unless @wagons.empty?
  end

  def move_previous_station
    return unless previous_station

    @station.send_train(self)
    @station = previous_station
    @station.get_train(self)
  end

  def move_next_station
    return unless next_station

    @station.send_train(self)
    @station = next_station
    @station.get_train(self)
  end

  def route_take(route)
    @route = route
    station = route.initial
    station.get_train(self)
    @station = station
    register_instance
  end

  private

  def next_station
    current_station_index = route.stations.index(station)
    return if current_station_index == (route.stations.length - 1)

    next_station_index = (current_station_index + 1)
    route.stations[next_station_index]
  end

  def previous_station
    current_station_index = route.stations.index(station)
    return if current_station_index.zero?

    previous_station_index = (current_station_index - 1)
    route.stations[previous_station_index]
  end

  def current_station
    station
  end
end
