# frozen_string_literal: true
# rubocop:disable all

require_relative 'manufacturer'
require_relative 'instancecounter'
require_relative 'validate'
require_relative 'station'
require_relative 'accessors'
require_relative 'train'
require_relative 'wagon'
require_relative 'train_cargo'
require_relative 'train_passenger'
require_relative 'route'
require_relative 'wagon_cargo'
require_relative 'wagon_passenger'

class Main
  def initialize
    @stations = []
    @trains = []
    @routes = []
  end

  def call
    print_menu
    loop do
      puts 'Выберите действие:'
      action = gets.chomp.to_i

      case action
      when 1 then create_new_station
      when 2 then list_stations_trains
      when 3 then create_new_train
      when 4 then create_new_route
      when 5 then edit_route
      when 6 then train_route_take
      when 7 then wagons_operation
      when 8 then move_train
      when 9 then show_trains_on_station
      when 10 then show_trains_wagons
      when 11 then take_place
      when 0 then break
      end
    end
  end

  private

  def print_menu
    puts '1. Новая станция'
    puts '2. Список станций и поездов'
    puts '3. Новый поезд'
    puts '4. Новый маршрут'
    puts '5. Редактирование маршрутов'
    puts '6. Назначение маршрута поезду'
    puts '7. Прицепить/отцепить вагоны к поезду'
    puts '8. Переместить поезд на следующую/предыдущую станцию'
    puts '9. Список поездов на станции'
    puts '10. Список вагонов у поезда'
    puts '11. Занять места или объем в вагоне'
    puts '0. Завершить программу'
  end

# rubocop:anable all

  def create_new_station
    puts 'Введите имя станции'
    @stations << Station.new(gets.chomp)
    puts "Вы создали станцию #{@stations.last.name}"
  end

  def list_stations_trains
    puts '1. Посмотреть список станций'
    puts '2. Посмотреть список поездов'
    choice = gets.chomp.to_i

    case choice
    when 1
      stations_list(@stations)
    when 2
      trains_list
    end
  end

  def stations_list(stations)
    stations.each_with_index do |station, i|
      puts "#{i}. #{station.name}"
    end
  end

  def trains_list
    @trains.each_with_index do |train, i|
      puts "#{i + 1}.  № #{train.number} - тип: #{train.type}"
    end
  end

  def train_selection
    puts 'Выберите поезд из списка'
    @trains.each_with_index { |train, i| puts "#{i}. #{train.number}" }
    @trains[gets.chomp.to_i]
  end

  def station_selection
    puts 'Выберите станцию'
    stations_list(@stations)
    @stations[gets.chomp.to_i]
  end

  def route_selection
    puts 'Выберите маршрут из списка:'
    @routes.each_with_index do |r, i|
      puts "#{i}. #{r.initial.name} — #{r.final.name}"
    end
    @routes[gets.chomp.to_i]
  end

  def wagon_selection(train)
    puts 'Выберите вагон'
    train.wagons.each_with_index { |wagon, i| puts "#{i}. #{wagon.number}" }
    train.wagons[gets.chomp.to_i]
  end

# rubocop: disable all

  def create_new_train
    train =
      begin
        puts "Введите номер поезда\n(три буквы или цифры, необязательный дефис" \
             ' и еще 2 буквы или цифры)'
        number = gets.chomp

        puts "Выберите тип поезда:\n1. пассажирский\n2. грузовой"

        action = gets.chomp.to_i
        case action
        when 1 then TrainPassenger.new(number)
        when 2 then TrainCargo.new(number)
        end
      rescue StandardError => e
        puts e
        retry
      end

    train.nil? ? puts('Неверное число') : @trains << train
  end

# rubocop: anable all

  def create_new_route
    puts 'Создайте сначала как минимум 2 станции' if @stations.size < 2

    stations_list(@stations)

    puts 'Выберите первую станцию маршрута'
    initial = @stations[gets.chomp.to_i]

    puts 'Выберите конечную станцию маршрута'
    final = @stations[gets.chomp.to_i]

    @routes << Route.new(initial, final)
  end

  def edit_route
    route = route_selection
    puts '1. Добавить станцию'
    puts '2. Удалить станцию'
    choice = gets.chomp.to_i

    case choice
    when 1
      add_station_to_route(route)
    when 2
      delete_station_from_route(route)
    end
  end

  def add_station_to_route(route_selection)
    route_selection.add_station(station_selection)
  end

  def delete_station_from_route(route)
    if route.stations.count < 2
      puts 'Вы не можете удалить начальную и конечную станции'
      nil

    else
      puts 'Какую станцию вы хотите удалить?'
      stations_list(route.stations)
      route.delete_station(route.stations[gets.chomp.to_i])
    end
  end

  def train_route_take
    if @trains.empty?
      puts 'Сначала создайте поезд'
      nil

    else
      train_selection.route_take(route_selection)
    end
  end

  def wagons_operation
    puts '1. Добавить вагоны к поезду'
    puts '2. Отцепить вагоны от поезда'
    choice = gets.chomp.to_i
    case choice
    when 1
      attach_wagons_to_train
    when 2
      detach_wagons_to_train
    end
  end

  def attach_wagons_to_train
    train = train_selection
    puts 'Введите № прицепляемого вагона'
    number = gets.chomp
    puts 'Введите количество мест или объем вагона'
    case train.type
    when 'passanger'
      train.attach_wagon(WagonPassanger.new(number, gets.chomp.to_i))
    when 'cargo'
      train.attach_wagon(WagonCargo.new(number, gets.chomp.to_i))
    end
  end

  def detach_wagons_to_train
    train = train_selection
    if train.wagons.size.zero?
      puts 'В составе нет вагонов, сначала прицепите вагон!'
    else
      puts train.wagons.to_s
      puts 'Введите название отцепляемого вагона'
      wagon = gets.chomp
      train.detach_wagon(wagon)
    end
  end

  def move_train
    puts '1. Переместить поезд на следующую станцию'
    puts '2. Переместить поезд на предыдущую станцию'
    choice = gets.chomp.to_i
    case choice
    when 1
      move_train_next_station
    when 2
      move_train_previous_station
    end
  end

  def move_train_next_station
    train_selection.move_next_station
  end

  def move_train_previous_station
    train_selection.move_previous_station
  end

  def show_trains_on_station
    station = station_selection
    puts 'На станции следующие поезда'
    station.trains_on_station do |train|
      puts "Номер: #{train.number}, тип: #{train.type}, вагонов: #{train.wagons.size}"
    end
  end

  def show_trains_wagons
    train = train_selection
    puts 'В составе поезда следующие вагоны:'
    train.trains_wagons do |wagon|
      case wagon.type
      when 'passanger'
        puts "№ #{wagon.number}, тип #{wagon.type} \nсвободно мест: #{wagon.vacanted_sits}, занято #{wagon.occupied_sits}"
      when 'cargo'
        puts "№ #{wagon.number}, тип #{wagon.type} \nсвободный объем: #{wagon.remaining_volume}, занято #{wagon.occupied_volume}"
      end
    end
  end

  def take_place
    train = train_selection
    wagon = wagon_selection(train)
    if train.instance_of?(TrainPassenger)
      puts 'Сколько мест занять?'
      gets.chomp.to_i.times { wagon.take_sit }
    elsif train.instance_of?(TrainCargo)
      puts 'Какой объем занять?'
      wagon.occupy_volume(gets.chomp.to_i)
    end
  end
end

Main.new.call
