class Team
  attr_accessor :abbr, :name, :nickname, :colors, :field, :players, :lineups
  attr_accessor :defense, :punting, :kicking, :kick_return, :punt_return

  class TeamColors
    attr_accessor :home_jersey, :home_letter
    attr_accessor :road_jersey, :road_letter

    def initialize
      @home_jersey = nil
      @home_letter = nil
      @road_jersey = nil
      @road_letter = nil
    end

  end

  class Lineup
    attr_reader :players
    attr_accessor :numbers

    def initialize( *players )
      @numbers = nil
      @players = players
    end

    def update_players( players )
      @numbers.each do |number|
        players.each do |player|
          if player.number == number
            @players.push player
            break
          end
        end
      end
    end

    def to_s
      s = ""
      @players.each do |player|
        s += sprintf "%2d ", player.number
      end

      return s.strip
    end

  end

  class Proficiency
    attr_accessor :player, :number, :attempts, :successful, :average

    def initialize
      @player     = nil
      @number     = nil
      @attempts   = nil
      @successful = nil
      @average    = nil
    end

    def update_player( players )
      players.each do |player|
        if player.number == @number
          @player = player
          return
        end
      end
    end

    def calc_successful( accuracy )
      @successful = (@attempts * (accuracy / 100)).to_i
    end

    def to_s
      if @average.nil?
        sprintf "%2d %2d %2d", @player.number, @successful, @attempts
      else
        sprintf "%2d %4.1f", @player.number, @average
      end
    end
  end

  class Player
    attr_reader   :name, :position, :punt_distance, :fg_accuracy
    attr_accessor :number, :rating, :year

    def initialize( number, name, position, rating, year )
      @number   = number
      @name     = name
      @position = position
      @rating   = rating
      @year     = year

      @punt_distance = nil
      @fg_accuracy   = nil

      @pos_heirarchy = { 'OT' =>  6, 'OG' =>  7, 'CR' =>  8, 'TE' =>  5, 'WR' =>  4, 'HB' =>  2, 'FB' =>  3, 'QB' =>  1,
                         'DE' => 10, 'DT' =>  9, 'NT' =>  9, 'LB' => 11, 'CB' => 12, 'DB' => 13, 'KI' => 14, 'PU' => 14 }
    end

    def is_running_back
      if @position == "HB" or @position == "FB"
        return true
      end

      return false
    end

    def is_receiver
      if @position == "WR"
        return true
      end

      return false
    end

    def set_fg_accuracy
      @fg_accuracy = ((@rating / 5.0) * 35.0) + 65.0
    end

    def set_punt_distance
      @punt_distance = ((@rating / 5.0) * 20.0) + 30.0
    end

    def convert_to_punter
      if @position != "KI"
        return
      end

      @position = "PU"
    end

    def <=>( other )
      i_values = get_comp_values
      o_values = other.get_comp_values

      i = 0
      while i < i_values.length  and (i_values[i] <=> o_values[i]) == 0
        i += 1
      end

      if i < i_values.length
        return i_values[i] <=> o_values[i]
      end

      return 0
    end

    def get_comp_values
      return [ @pos_heirarchy.fetch( @position ), (5.0 - @rating) ]
    end

    def to_s
      return sprintf "%2d %-25s %s %3.1f  $ %s\n",@number, "\"#{@name}\"", (@position == "PU") ? "KI" : @position, @rating, @year
    end

  end

  def initialize
    @abbr         = nil
    @name         = nil
    @nickname     = nil
    @colors       = TeamColors.new
    @players      = Array.new
    @new_players  = Array.new
    @lineups      = Hash.new
    @defense      = nil
    @generator    = nil
    @punting      = Proficiency.new
    @kicking      = Proficiency.new
    @kick_return  = Proficiency.new
    @punt_return  = Proficiency.new
  end

  def add_player( number, name, position, rating, year )
    @players.push Player.new number, name, position, rating, year
  end

  def add_lineup( name, numbers )
    lineup = Lineup.new()
    lineup.numbers = numbers
    @lineups.store name, lineup
  end

  def get_proficiency( number, average, attempts = nil, successful = nil )
    proficiency = Proficiency.new
    proficiency.number = number
    proficiency.average = average
    proficiency.attempts = attempts
    proficiency.successful = successful
    return proficiency
  end

  def mark_punter
    @punting.player.convert_to_punter
  end

  def init_rating_scale()
    @rating_scale = [ { 'rating' => 5.0, 'value' =>    1 },
                      { 'rating' => 4.9, 'value' =>    3 },
                      { 'rating' => 4.8, 'value' =>    5 },
                      { 'rating' => 4.7, 'value' =>    6 },
                      { 'rating' => 4.6, 'value' =>    7 },
                      { 'rating' => 4.5, 'value' =>    9 },
                      { 'rating' => 4.4, 'value' =>   10 },
                      { 'rating' => 4.3, 'value' =>   11 },
                      { 'rating' => 4.2, 'value' =>   12 },
                      { 'rating' => 4.1, 'value' =>   13 },
                      { 'rating' => 4.0, 'value' =>   14 },
                      { 'rating' => 3.9, 'value' =>   15 },
                      { 'rating' => 3.8, 'value' =>   19 },
                      { 'rating' => 3.7, 'value' =>   24 },
                      { 'rating' => 3.6, 'value' =>   29 },
                      { 'rating' => 3.5, 'value' =>   33 },
                      { 'rating' => 3.4, 'value' =>   50 },
                      { 'rating' => 3.3, 'value' =>   75 },
                      { 'rating' => 3.2, 'value' =>  100 },
                      { 'rating' => 3.1, 'value' =>  125 },
                      { 'rating' => 3.0, 'value' =>  150 },
                      { 'rating' => 2.9, 'value' =>  200 },
                      { 'rating' => 2.8, 'value' =>  300 },
                      { 'rating' => 2.7, 'value' =>  400 },
                      { 'rating' => 2.6, 'value' =>  500 },
                      { 'rating' => 2.5, 'value' =>  600 },
                      { 'rating' => 2.4, 'value' =>  850 },
                      { 'rating' => 2.3, 'value' => 1000 },
                      { 'rating' => 2.2, 'value' =>  950 },
                      { 'rating' => 2.1, 'value' =>  700 },
                      { 'rating' => 2.0, 'value' =>  500 },
                      { 'rating' => 1.9, 'value' =>  300 },
                      { 'rating' => 1.8, 'value' =>  250 },
                      { 'rating' => 1.7, 'value' =>  200 },
                      { 'rating' => 1.6, 'value' =>  150 },
                      { 'rating' => 1.5, 'value' =>  100 },
                      { 'rating' => 1.4, 'value' =>   80 },
                      { 'rating' => 1.3, 'value' =>   65 },
                      { 'rating' => 1.2, 'value' =>   50 },
                      { 'rating' => 1.1, 'value' =>   35 },
                      { 'rating' => 1.0, 'value' =>   20 } ]

    @scale_total = 0

    @rating_scale.each do |entry|
      @scale_total += entry.fetch 'value'
    end
  end

  def determine_rating()
    roll = @generator.rand @scale_total + 1

    @rating_scale.each do |entry|
      if (roll -= entry.fetch 'value') <= 0
        return entry.fetch 'rating'
      end
    end

    return 1.0
  end

  def generate_team( player_names )
    @generator   = Random.new Time.new.usec

    init_rating_scale

    @defense          = (@generator.rand( 100 ) >= 50) ? 43 : 34
    @kicking.attempts =  @generator.rand( 31 ) + 20

    positions = [ "CB", "CB", "CB", "CB", "CR", "CR", "CR", "DB", "DB", "DB", "DE", "DE", "DE",
                  "FB", "FB", "HB", "HB", "LB", "LB", "LB", "LB", "LB", "OG", "OG", "OG", "OT",
                  "OT", "OT", "QB", "QB", "QB", "TE", "TE", "TE", "WR", "WR", "WR", "WR" ]

    if @defense == 34
      positions += [ "LB", "LB", "NT", "NT", "NT" ]
    else
      positions += [ "DE", "DT", "DT", "DT", "DT" ]
    end

    positions += [ "KI", "PU" ]

    positions.each do |pos|
      @players.push generate_player( player_names.pop, pos )
    end

    @players.sort!
  end

  def generate_player( name, position, year = nil )
    number = get_player_number position
    rating = determine_rating

    if year.nil?
      year = get_player_class
    end

    player = Player.new number, name, position, rating, year

    if position == "KI"
      player.set_fg_accuracy
      @kicking.player  = player
      @kicking.calc_successful( player.fg_accuracy )
    end

    if position == "PU"
      player.set_punt_distance
      @punting.player  = player
      @punting.average = player.punt_distance
    end

    return player
  end

  def get_player_number( position )
    number = 0
    while number == 0
      number = case position
      when "OT" then @generator.rand( 20 ) + 60
      when "OG" then @generator.rand( 20 ) + 60
      when "CR" then @generator.rand( 20 ) + 60
      when "TE" then @generator.rand( 10 ) + 80
      when "WR" then @generator.rand( 10 ) + 80
      when "HB" then @generator.rand( 10 ) + 20
      when "FB" then @generator.rand( 10 ) + 30
      when "QB" then @generator.rand( 19 ) +  1
      when "DE" then @generator.rand( 10 ) + 90
      when "DT" then @generator.rand( 10 ) + 90
      when "NT" then @generator.rand( 10 ) + 90
      when "LB" then @generator.rand( 10 ) + 50
      when "CB" then @generator.rand( 20 ) + 20
      when "DB" then @generator.rand( 10 ) + 40
      when "KI" then @generator.rand( 19 ) +  1
      when "PU" then @generator.rand( 19 ) +  1
      end

      @players.each do |player|
        if number == player.number
          number = 0
          break
        end
      end

      if number != 0
        @new_players.each do |player|
          if number == player.number
            number = 0
            break
          end
        end
      end
    end

    return number
  end

  def get_player_class
    case @generator.rand 4
    when 0 then "Freshman"
    when 1 then "Sophomore"
    when 2 then "Junior"
    when 3 then "Senior"
    end
  end

  def graduate_players( player_names )
    @generator    = Random.new Time.new.usec
    @lineups      = Hash.new
    @punting      = Proficiency.new
    @kicking      = Proficiency.new
    @kick_return  = Proficiency.new
    @punt_return  = Proficiency.new

    init_rating_scale

    @kicking.attempts    =  @generator.rand( 31 ) + 20

    @new_players = Array.new
    @players.each do |player|
      if player.year == "Senior"
        player.number = 0
        @new_players.push generate_player( player_names.pop, player.position, "Freshman" )
      else
        graduate_player( player )
        @new_players.push player
      end
    end

    @players     = @new_players.sort
    @new_players = Array.new
  end

  def graduate_player( player )
    if player.rating < 5.0
      potential = (5.0 - player.rating) / 2.0
      player.rating += @generator.rand( potential ).round 1
    end

    if    player.year == "Freshman"
      player.year = "Sophomore"
    elsif player.year == "Sophomore"
      player.year = "Junior"
    elsif player.year == "Junior"
      player.year = "Senior"
    end

    if player.position == "KI"
      player.set_fg_accuracy
      @kicking.player = player
      @kicking.calc_successful( player.fg_accuracy )
    end

    if player.position == "PU"
      player.set_punt_distance
      @punting.player  = player
      @punting.average = player.punt_distance
    end
  end

  def set_lineups
    returner = get_top_players( "HB", "WR", "CB", "DB" )[0]
    @kick_return.player = returner
    @punt_return.player = returner

    @kick_return.average =  @generator.rand( 15.0 +  @kick_return.player.rating        ) + 15.0
    @punt_return.average =  @generator.rand( 10.0 + (@kick_return.player.rating / 2.0) ) +  5.0

    @lineups.store "LO", select_offense_lineup
    @lineups.store "LD", select_defense_lineup
    @lineups.store "LK", select_kickoff_lineup
    @lineups.store "LP", select_punt_lineup
    @lineups.store "LR", select_kickoff_return_lineup
    @lineups.store "LQ", select_punt_return_lineup
    @lineups.store "LF", select_fieldgoal_lineup
  end

  def select_offense_lineup
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #
    #   OFFENSE
    #
    #  .LO 1 2 3 4 5 6 7 8 9 A B
    #
    #
    #  7       1 2 3 4 5 6
    #              B             A
    #              9
    #              8
    #
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    guards    = get_top_players "OG"
    tackles   = get_top_players "OT"
    receivers = get_top_players "WR"

    # OT  OG  CR  OG  OT  TE  SE  HB  FB  FL  QB
    return Lineup.new tackles[0],
    guards[1],
    get_top_players( "CR" )[0],
    guards[0],
    tackles[1],
    get_top_players( "TE" )[0],
    receivers[0],
    get_top_players( "HB" )[0],
    get_top_players( "FB" )[0],
    receivers[1],
    get_top_players( "QB" )[0]
  end

  def select_defense_lineup
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #
    #   DEFENSE
    #
    #  .LD 1 2 3 4 5 6 7 8 9 A B
    #
    #
    #      9              A
    #
    #        4   5   6   7
    #  8       1   2   3       B
    #
    #--------------------------------------------------
    #      9              A
    #
    #        5     6     7
    #  8      1  2   3  4      B
    #
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    tackles     = get_top_players "NT", "DT"
    ends        = get_top_players "DE"
    linebackers = get_top_players "LB"
    corners     = get_top_players "CB"
    safeties    = get_top_players "DB"

    if @defense == 34
      # DE  NT  DE  LB  LB  LB  LB  CB  DB  DB  CB
      return Lineup.new ends[1],
      tackles[0],
      ends[0],
      linebackers[0],
      linebackers[2],
      linebackers[1],
      linebackers[3],
      corners[0],
      safeties[1],
      safeties[0],
      corners[1]
    else
      # DE  DT  DT  DE  LB  LB  LB  CB  DB  DB  CB
      return Lineup.new ends[0],
      tackles[1],
      tackles[0],
      ends[1],
      linebackers[2],
      linebackers[0],
      linebackers[1],
      corners[0],
      safeties[1],
      safeties[0],
      corners[1]
    end
  end

  def select_kickoff_lineup
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #
    #   KICKOFF
    #
    #  .LK 1 2 3 4 5 6 7 8 9 A B
    #
    #
    #  1 2 3 4 5   6 7 8 9 A
    #
    #            B
    #
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    big    = get_top_players "FB", "TE", "LB"
    fast   = get_top_players "HB", "WR", "CB", "DB"
    kicker = nil

    @players.each do |player|
      if player.position == "KI"
        kicker = player
        break
      end
    end

    # SP  SP  SZ  SZ  SZ  SZ  SZ  SZ  SP  SP  KI
    return Lineup.new fast[0],
    fast[3],
    big[5],
    big[3],
    big[0],
    big[1],
    big[2],
    big[4],
    fast[2],
    fast[1],
    kicker
  end

  def select_punt_lineup
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #
    #   PUNT
    #
    #  .LP 1 2 3 4 5 6 7 8 9 A B
    #
    #
    #  8     1 2 3 4 5 6 7     A
    #                9
    #
    #
    #              B
    #
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    guards    = get_top_players "OG"
    tackles   = get_top_players "OT"
    receivers = get_top_players "WR"
    ends      = get_top_players "TE"
    punter    = nil

    @players.each do |player|
      if player.position == "PU"
        punter = player
        break
      end
    end

    # TE  OT  OG  CR  OG  OT  TE  WR  HB  WR  PU
    return Lineup.new ends[1],
    tackles[0],
    guards[1],
    get_top_players( "CR" )[0],
    guards[0],
    tackles[1],
    ends[0],
    receivers[0],
    get_top_players( "HB" )[0],
    receivers[1],
    punter
  end

  def select_kickoff_return_lineup
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #
    #   KICKOFF RETURN
    #
    #  .LR 1 2 3 4 5 6 7 8 9 A B
    #
    #
    #            A   B
    #
    #              9
    #
    #          6   7   8
    #
    #      1   2   3   4   5
    #
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    big = get_top_players "CR", "OG", "OT", "DE", "DT", "NT"
    med = get_top_players "FB", "TE", "LB"
    ret = get_top_players "HB", "WR", "CB", "DB"

    # LG  LG  LG  LG  LG  MD  MD  MD  MD  KR  KR
    return Lineup.new big[3],
    big[2],
    big[0],
    big[1],
    big[4],
    med[1],
    med[0],
    med[2],
    med[3],
    ret[1],
    ret[0]
  end

  def select_punt_return_lineup
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #
    #   PUNT RETURN
    #
    #  .LQ 1 2 3 4 5 6 7 8 9 A B
    #
    #            B
    #
    #
    #        9         A
    #
    #
    #  1     2 3 4 5 6 7     8
    #
    #--------------------------------------------------
    #
    #   FIELD GOAL DEFENSE (same lineup as punt return)
    #
    #  .LQ 1 2 3 4 5 6 7 8 9 A B
    #
    #       9             A
    #      1 2 3 4 5 6 7 8 9
    #
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    big  = get_top_players "LB", "DE", "DT", "NT"
    med  = get_top_players "FB", "TE"
    fast = get_top_players "HB", "WR", "CB", "DB"

    # FS  LG  LG  LG  LG  LG  LG  FS  MD  MD  FS
    return Lineup.new fast[1],
    big[4],
    big[3],
    big[0],
    big[1],
    big[2],
    big[5],
    fast[2],
    med[1],
    med[0],
    fast[0]
  end

  def select_fieldgoal_lineup
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #
    #   FIELD GOAL
    #
    #  .LF 1 2 3 4 5 6 7 8 9 A B
    #
    #
    #        1 2 3 4 5 6 7
    #       8             9
    #
    #               A
    #              B
    #
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    guards  = get_top_players "OG"
    tackles = get_top_players "OT"
    ends    = get_top_players "TE"
    wings   = get_top_players "FB"
    kicker = nil

    @players.each do |player|
      if player.position == "KI"
        kicker = player
        break
      end
    end

    # TE  OT  OG  CR  OG  OT  TE  FB  FB  QB  KI
    return Lineup.new ends[1],
    tackles[0],
    guards[1],
    get_top_players( "CR" )[0],
    guards[0],
    tackles[1],
    ends[0],
    wings[0],
    wings[1],
    get_top_players( "QB" )[0],
    kicker
  end

  def get_top_players( *positions )
    players = Array.new

    @players.each do |player|
      next if !positions.include? player.position

      i = 0
      while i < players.length
        break if player.rating > players[i].rating
        i += 1
      end

      players.insert i, player
    end

    return players
  end

  def compute_averate_player_rating( players )
    total = 0
    players.each do |player|
      total += player.rating
    end
    total = total / players.length

    return total
  end

  def get_average_team_rating
    return compute_averate_player_rating @players
  end

  def get_average_lineup_rating( lineup )
    return compute_averate_player_rating  @lineups.fetch( lineup ).players
  end

  def get_team_rating
    team_r = get_average_team_rating
    off_r = get_average_lineup_rating ".LO"
    def_r = get_average_lineup_rating ".LD"

    return team_r + (off_r * 2) + (def_r * 2)
  end

  def determine_style
    rbs = []
    wrs = []

    @players.each do |player|
      if player.is_running_back
        rbs.push player
      end

      if player.is_receiver
        wrs.push player
      end
    end

    rbs.sort!
    wrs.sort!

    rbs.slice! 2..-1
    wrs.slice! 2..-1

    rbavg = (rbs[0].rating + rbs[1].rating) / 2.0
    wravg = (wrs[0].rating + wrs[1].rating) / 2.0

    if (rbavg - wravg) >= 1.0
      return :rushing
    end

    if (wravg - rbavg) >= 1.0
      return :passing
    end

    if (rbs[0].rating - wrs[0].rating) >= 1.0
      return :rushing
    end

    if (wrs[0].rating - rbs[0].rating) >= 1.0
      return :passing
    end

    return :balanced
  end

  def print_team( file=$stdout )
    file.print ".NA \"#{@name}\"\n"
    file.print ".PU #{@punting}\n"
    file.print ".FG #{@kicking}\n"
    file.print ".KR #{@kick_return}\n"
    file.print ".PR #{@punt_return}\n"
    file.printf ".HJ %2d %2d %2d\n", *@colors.home_jersey
    file.printf ".HL %2d %2d %2d\n", *@colors.home_letter
    file.printf ".VJ %2d %2d %2d\n", *@colors.road_jersey
    file.printf ".VL %2d %2d %2d\n", *@colors.road_letter
    file.print ".HF \"#{@nickname} Home Field\" O N\n"
    file.printf ".ND %d\n", @defense
    file.print ".PL\n"

    @players.each do |player|
      file.print player.to_s
    end

    @lineups.each do |lineup, players|
      file.printf ".%s %s\n", lineup, players
    end

    file.print ".EN\n"
  end

  def write_team
    open "#{@abbr}.team", "w" do |file|
      print_team file
    end
  end

end
