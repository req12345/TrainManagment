# frozen_string_literal: true

class WagonPassanger < Wagon
  attr_reader :occupied_sits, :free_sits

  def initialize(number, total_sits)
    @type = 'passanger'
    @total_sits = total_sits
    @occupied_sits = 0
    super(number)
  end

  def take_sit
    @occupied_sits += 1
  end

  def vacanted_sits
    @total_sits - @occupied_sits
  end
end
