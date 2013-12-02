require_relative 'analyzer'
require_relative 'calculator'

module SandiMeter
  class FileScanner
    def initialize(log_errors = false)
      @log_errors = log_errors
      @calculator = SandiMeter::Calculator.new
    end

    def scan(path, store_details = false)
      read_ignore_file(path) unless @exclude_patterns

      if File.directory?(path)
        scan_dir(path)
      else
        scan_file(path)
      end

      @calculator.calculate!(store_details)
    end

    private
    def scan_dir(path)
      Dir["#{path}/**/*.rb"].reject { |f| !@exclude_patterns.to_s.empty? && f =~ /#{@exclude_patterns}/ }.each do |file|
        scan_file(file)
      end
    end

    def read_ignore_file(path)
      ignore_file_path = File.join(path, 'sandi_meter', '.sandi_meter')
      if File.exists?(ignore_file_path)
        @exclude_patterns ||= File.read(ignore_file_path).split("\n").join("|")
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
