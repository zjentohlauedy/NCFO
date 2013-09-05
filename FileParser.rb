class FileParser

  def initialize( parser )
    @parser = parser
  end


  def read_file( filename )
    file = open filename
    yield file
  ensure
    file.close if file
  end


  def process_file( filename )
    read_file filename do |file|
      while line = file.gets
        @parser.parse line
      end
    end
  end

  private :read_file
end
