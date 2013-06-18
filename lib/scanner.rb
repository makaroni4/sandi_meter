require_relative 'analyzer'
require_relative 'calculator'

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

    output
  end

  private
  def output
  end

  def scan_dir(path)
    Dir["#{path}/**/*.rb"].each do |file|
      scan_file(file)
    end
  end

  def scan_file(path)
    analyzer = Analyzer.new
    data = analyzer.analyze(path)
    @calculator.push(data)
  end
end
