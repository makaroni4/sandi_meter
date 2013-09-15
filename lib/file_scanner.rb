require_relative 'analyzer'
require_relative 'calculator'

class FileScanner
  def initialize(log_errors = false)
    @log_errors = log_errors
    @calculator = Calculator.new
  end

  def scan(path)
    if File.directory?(path)
      scan_dir(path)
    else
      scan_file(path)
    end

    @calculator.calculate!
  end

  private
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
      if @log_errors
        puts "Checkout #{path} for:"
        puts "\t#{e.message}"
      end
    end
  end
end
