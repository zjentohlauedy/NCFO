class ScheduleParser

  class Game
    attr_reader :played, :home_team, :road_team, :home_score, :road_score
    attr_accessor :televised, :number

    def initialize( road_team, home_team, road_score = nil, home_score = nil )
      @home_team = home_team
      @road_team = road_team
      @home_score = home_score.to_i
      @road_score = road_score.to_i

      @number = 0

      @played = !home_score.nil?
      @televised = false
    end
  end

  class Day
    attr_reader :day, :games, :completed
    attr_accessor :televised

    def initialize( day )
      @day = day.to_i
      @games = []
      @completed = false
      @televised = false
    end

    def add_game( game )
      game.number = @games.length + 1
      @games.push game
      check_complete
    end

    def check_complete
      @completed = true

      @games.each do |game|
        if !game.played
          @completed = false
          return
        end
      end
    end

    private :check_complete
  end

  class Schedule
    attr_reader :days

    def initialize
      @days = []
    end

    def add_day( day )
      @days.push day
    end

    def reset_tv
      days.each do |day|
        if day.televised
          day.games.each do |game|
            if game.televised
              game.televised = false
            end
          end

          day.televised = false
        end
      end
    end
  end

  attr_reader :schedule

  def initialize
    @line_count  = 0
    @skip_record = false
    @road_fields = []
    @home_fields = []
    @schedule = Schedule.new
  end


  def parse( line )

    line.chomp!

    @line_count += 1

    if @line_count == 1
      return
    end

    if @skip_record
      return
    end

    unless @road_fields.length > 0
      @road_fields = line.split ","
    else
      @home_fields = line.split "," unless @home_fields.length > 0
    end

    if @home_fields.length > 0  && @road_fields.length > 0

      gameday = Day.new @home_fields[0]

      index = 1

      while index < @home_fields.length

        if @road_fields[index+1] && @road_fields[index+1].length > 0
          gameday.add_game Game.new @road_fields[index], @home_fields[index], @road_fields[index+1], @home_fields[index+1]
        else
          gameday.add_game Game.new @road_fields[index], @home_fields[index]
        end

        index += 2
      end

      schedule.add_day gameday

      @road_fields = []
      @home_fields = []
    end

  end

end
