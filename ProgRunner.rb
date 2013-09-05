class ProgRunner

  def initialize( path, program )
    @executable = "#{path}/#{program}"
  end

  def execute( *args )
    @output = File.read "|#{@executable} #{args.join ' '}"
    @result = $?.success?
  end

  def success?
    return @result
  end

  def has_output?
    if @output.nil?
      return false
    end

    if @output == ""
      return false
    end

    return true
  end

  def get_output
    return @output
  end

end
