#!/usr/bin/env ruby
#
location = File.dirname __FILE__

$: << "#{location}"
require 'FileParser'
require 'TeamParser'

class Conference
  attr_reader :name, :schools

  def initialize( name, schools )
    @name = name
    @schools = schools
  end

end


conferences = [ Conference.new( 'New England', [ 'uct', 'ume', 'uma', 'unh', 'uri', 'uvt' ] ),
                Conference.new( 'Atlantic',    [ 'ude', 'umd', 'unj', 'uny', 'uva', 'uwv' ] ),
                Conference.new( 'Southeast',   [ 'ual', 'ufl', 'uga', 'unc', 'usc', 'utn' ] ),
                Conference.new( 'Great Lake',  [ 'uil', 'uin', 'uky', 'umi', 'uoh', 'upa' ] ),
                Conference.new( 'Southwest',   [ 'uaz', 'uca', 'uco', 'unv', 'unm', 'uut' ] ),
                Conference.new( 'Northwest',   [ 'uid', 'umt', 'une', 'uor', 'uwa', 'uwy' ] ),
                Conference.new( 'Midwest',     [ 'uia', 'uks', 'umn', 'und', 'usd', 'uwi' ] ),
                Conference.new( 'South',       [ 'uar', 'ula', 'ums', 'umo', 'uok', 'utx' ] ) ]

conferences.each do |conference|
  print "#{conference.name}\n"

  conference.schools.each do |school|
    tp = TeamParser.new
    fp = FileParser.new tp

    fp.process_file "#{school}.team"

    team = tp.team

    printf "%-16s %3.1f  %3.1f  %3.1f\n", team.name,
    team.get_average_team_rating,
    team.get_average_lineup_rating( ".LO" ),
    team.get_average_lineup_rating( ".LD" )
  end

  print "\n"
  print "\n"
end
