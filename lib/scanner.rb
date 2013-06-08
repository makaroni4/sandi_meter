require_relative 'analyzer'

class FileScanner
  def scan(path)
    if File.directory?(path)
      scan_dir(path)
    else
      scan_file(path)
    end
  end

  private
  def scan_dir(path)
    Dir["#{path}/**/*.rb"].each do |file|
      scan_file(file)
    end
  end

  def scan_file(path)
    analyzer = Analyzer.new
    analyzer.analyze(path)
  end
end
