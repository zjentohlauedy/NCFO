#!/usr/bin/env ruby
#
location = File.dirname __FILE__

$: << "#{location}"
require 'ProgRunner'

class Conference
  attr_reader :name, :schools

  def initialize( name, schools )
    @name = name
    @schools = schools
  end

end


record_prog = ProgRunner.new location, "get_record"
stats_prog = ProgRunner.new location, "get_player_stats"

conferences = [ Conference.new( 'New England', [ 'uct', 'ume', 'uma', 'unh', 'uri', 'uvt' ] ),
                Conference.new( 'Atlantic',    [ 'ude', 'umd', 'unj', 'uny', 'uva', 'uwv' ] ),
                Conference.new( 'Southeast',   [ 'ual', 'ufl', 'uga', 'unc', 'usc', 'utn' ] ),
                Conference.new( 'Great Lake',  [ 'uil', 'uin', 'uky', 'umi', 'uoh', 'upa' ] ),
                Conference.new( 'Southwest',   [ 'uaz', 'uca', 'uco', 'unv', 'unm', 'uut' ] ),
                Conference.new( 'Northwest',   [ 'uid', 'umt', 'une', 'uor', 'uwa', 'uwy' ] ),
                Conference.new( 'Midwest',     [ 'uia', 'uks', 'umn', 'und', 'usd', 'uwi' ] ),
                Conference.new( 'South',       [ 'uar', 'ula', 'ums', 'umo', 'uok', 'utx' ] ) ]

Blue_Conferences = ['New England', 'Atlantic', 'Southeast', 'Great Lake']
Red_Conferences  = ['Southwest', 'Northwest', 'Midwest', 'South']

if ARGV.length > 0
  desired_conference = ARGV[0]
end

conferences.each do |conference|
  if !desired_conference.nil?
    if    desired_conference == "Blue"
      next if !Blue_Conferences.include? conference.name
    elsif desired_conference == "Red"
      next if !Red_Conferences.include? conference.name
    elsif desired_conference != conference.name
      next
    end
  end

  print "#{conference.name}\n"
  print "\n"

  conference.schools.each do |school|
    args = "#{school}.stat"

    record_prog.execute args

    (name, wins, losses, ties) = record_prog.get_output.split /,/

    printf "%s  %2d - %2d - %2d\n", name, wins, losses, ties
    printf "\n"

    stats_prog.execute args

    print stats_prog.get_output
    printf "\n"
  end
end
