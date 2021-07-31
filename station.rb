# frozen_string_literal: true

class Station
  include InstanceCounter
  include Validation

  validate :name, :presence
  validate :name, :name_length

  @stations = []

  attr_reader :trains, :name

  def initialize(name)
    @name = name
    @trains = []
    @stations << self
    validate!
    register_instance
  end

  def trains_on_station(&block)
    @trains.each(&block)
  end

  def valid?
    validate!
    true
  rescue StandardError
    false
  end

  def self.all
    @stations
  end

  def get_train(train)
    @trains << train
  end

  def send_train(train)
    @trains.delete(train)
  end

  def trains_by_type
    list = { 'cargo': [], 'passanger': [] }
    trains.each do |train|
      list[train.type.to_sym] << train
      puts "Пассажирские поезда: #{list[:passanger].map(&:number).join(', ')}"
      puts "Всего:  #{list[:passanger].size}"
      puts "Грузовые поезда: #{list[:cargo].map(&:number).join(', ')}"
      puts "Всего:  #{list[:cargo].size}"
    end
  end
end
