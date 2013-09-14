require_relative 'analyzer'
require_relative 'calculator'
require_relative 'formatter'

class FileScanner
  def initialize
    @calculator = Calculator.new
  end

  def scan(path)
    if File.directory?(path)
      scan_dir(path)
    else
      scan_file(path)
    end

    @calculator.calculate!
    output
  end

  private
  def output
    formatter = Formatter.new(@calculator)
    formatter.output
  end

  def scan_dir(path)
    Dir["#{path}/**/*.rb"].each do |file|
      scan_file(file)
    end
  end

  def scan_file(path)
    begin
      analyzer = Analyzer.new
      data = analyzer.analyze(path)
      @calculator.push(data)
    rescue Exception => e
      puts path
      puts "ERROR: #{e.message}"
    end
  end
end
