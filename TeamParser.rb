require 'Team'

class TeamParser
  attr_reader :team

  def initialize
    @team = Team.new
  end

  def parse( line )
    line.chomp!

    if /^\.NA/.match line
      @team.name = line.split( /"/ )[1]
    end

    if /^\.PU/.match line
      fields = line.split( / +/ )
      @team.punting = @team.get_proficiency( fields[1].to_i, fields[2].to_f )
    end

    if /^\.FG/.match line
      fields = line.split( / +/ )
      @team.kicking = @team.get_proficiency( fields[1].to_i, nil, fields[2].to_i, fields[3].to_i )
    end

    if /^\.KR/.match line
      fields = line.split( / +/ )
      @team.kick_return = @team.get_proficiency( fields[1].to_i, fields[2].to_f )
    end

    if /^\.PR/.match line
      fields = line.split( / +/ )
      @team.punt_return = @team.get_proficiency( fields[1].to_i, fields[2].to_f )
    end

    if /^\.HJ/.match line
      fields = line.split( / +/ )
      @team.colors.home_jersey = [ fields[1], fields[2], fields[3] ]
    end

    if /^\.HL/.match line
      fields = line.split( / +/ )
      @team.colors.home_letter = [ fields[1], fields[2], fields[3] ]
    end

    if /^\.VJ/.match line
      fields = line.split( / +/ )
      @team.colors.road_jersey = [ fields[1], fields[2], fields[3] ]
    end

    if /^\.VL/.match line
      fields = line.split( / +/ )
      @team.colors.road_letter = [ fields[1], fields[2], fields[3] ]
    end

    if /^\.HF/.match line
      @team.nickname = ""
      field = line.split( /"/ )[1]
      field.split( / / ).each do |word|
        break if word == "Home"
        @team.nickname += "#{word} "
      end
      @team.nickname.strip!
    end

    if /^\.ND/.match line
      @team.defense = line.split( / +/ )[1].to_i
    end

    if /^[ 0-9][0-9]/.match line
      fields = line.strip.tr('"', '').split( / +/ )
      @team.add_player fields[0].to_i, "#{fields[1]} #{fields[2]}", fields[3], fields[4].to_f, fields[6]
    end

    if /^\.L[DFKOPRQ]/.match line
      fields = line.strip.split( / +/ )
      @team.add_lineup fields[0], fields[1..-1].collect { |f| f.to_i }
    end

    if /^\.EN/.match line
      # convert player numbers to player objects in Team
      @team.punting.update_player @team.players
      @team.kicking.update_player @team.players
      @team.kick_return.update_player @team.players
      @team.punt_return.update_player @team.players
      @team.mark_punter

      @team.lineups.each do |key, lineup|
        lineup.update_players @team.players
      end
    end
  end

end
