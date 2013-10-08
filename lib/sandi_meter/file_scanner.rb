require_relative 'analyzer'
require_relative 'calculator'

module SandiMeter
  class FileScanner
    def initialize(log_errors = false)
      @log_errors = log_errors
      @calculator = SandiMeter::Calculator.new
    end

    def scan(path, store_details = false)
      if File.directory?(path)
        scan_dir(path)
      else
        scan_file(path)
      end

      @calculator.calculate!(store_details)
    end

    private
    def scan_dir(path)
      Dir["#{path}/**/*.rb"].each do |file|
        scan_file(file)
      end
    end

    def scan_file(path)
      begin
        analyzer = SandiMeter::Analyzer.new
        data = analyzer.analyze(path)
        @calculator.push(data)
      rescue Exception => e
        if @log_errors
          # TODO
          # add backtrace
          puts "Checkout #{path} for:"
          puts "\t#{e.message}"
        end
      end
    end
  end
end
