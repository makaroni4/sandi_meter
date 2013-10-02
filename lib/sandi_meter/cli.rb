require 'mixlib/cli'
require 'sandi_meter/file_scanner'
require 'sandi_meter/formatter'
require 'sandi_meter/logger'
require 'sandi_meter/html_generator'

module SandiMeter
  class CommandParser
    include Mixlib::CLI

    option :path,
      short: "-p PATH",
      long: "--path PATH",
      description: "Path to folder or file to analyze",
      default: "."

    option :log,
      short: "-l",
      long: "--log",
      description: "Show syntax error and indentation log output",
      boolean: true

    option :details,
      short: "-d",
      long: "--details",
      description: "Show details (path, line number)",
      boolean: true

    option :graph,
      short: "-g",
      long: "--graph",
      description: "Create folder and log data to graph",
      boolean: true

    option :help,
      short: "-h",
      long: "--help",
      description: "Help",
      on: :tail,
      boolean: true,
      show_options: true,
      exit: 0

    option :rules,
      short: "-r",
      long: "--rules",
      description: "Show rules",
      boolean: 0
  end

  class CLI
    def self.execute
      cli = CommandParser.new
      cli.parse_options

      if cli.config[:rules]
        show_sandi_rules
        exit 0
      end

      scanner = SandiMeter::FileScanner.new(cli.config[:log])
      data = scanner.scan(cli.config[:path], cli.config[:details] || cli.config[:graph])

      formatter = SandiMeter::Formatter.new

      formatter.print_data(data)

      if cli.config[:graph]
        if File.directory?(cli.config[:path])
          logger = SandiMeter::Logger.new
          logger.log!(cli.config[:path], data)

          html_generator = SandiMeter::HtmlGenerator.new
          html_generator.copy_assets!(cli.config[:path])
          html_generator.generate_data!(cli.config[:path])
          html_generator.generate_details!(cli.config[:path], data)

          system "open sandi_meter/index.html"
        else
          puts "WARNING!!! HTML mode works only if you scan folder."
        end
      end
    end

    def self.show_sandi_rules
      puts %(
        1. 100 lines per class
        2. 5 lines per method
        3. 4 params per method call (and don't even try cheating with hash params)
        4. 1 instance variables per controller' action
      )
    end
  end
end
