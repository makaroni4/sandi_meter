# encoding: utf-8
require 'mixlib/cli'
require 'sandi_meter/file_scanner'
require 'sandi_meter/formatter'
require 'sandi_meter/json_formatter'
require 'sandi_meter/rules_checker'
require 'sandi_meter/logger'
require 'sandi_meter/version'
require 'sandi_meter/html_generator'
require 'yaml'
require 'json'

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
      description: "CLI mode. Show details (path, line number)",
      boolean: true

    option :graph,
      short: "-g",
      long: "--graph",
      description: "HTML mode. Create folder, log data and output stats to HTML file.",
      boolean: true

    option :version,
      short: "-v",
      long: "--version",
      description: "Gem version",
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

    option :json,
      long: "--json",
      description: "Output as JSON",
      boolean: false
  end

  class CLI
    class << self
      def execute
        cli = CommandParser.new
        cli.parse_options

        if cli.config[:graph]
          log_dir_path = File.join(cli.config[:path], 'sandi_meter')
          FileUtils.mkdir(log_dir_path) unless Dir.exists?(log_dir_path)

          create_config_file(cli.config[:path], 'sandi_meter/.sandi_meter', %w(db vendor).join("\n"))
          create_config_file(cli.config[:path], 'sandi_meter/config.yml', YAML.dump({ threshold: 90 }))
        end

        if cli.config[:version]
          puts version_info
          exit 0
        end

        if cli.config[:rules]
          show_sandi_rules
          exit 0
        end

        scanner = SandiMeter::FileScanner.new(cli.config[:log])
        data = scanner.scan(cli.config[:path], cli.config[:details] || cli.config[:graph])

        if cli.config[:json]
          formatter = SandiMeter::JsonFormatter.new
        else
          formatter = SandiMeter::Formatter.new
        end

        formatter.print_data(data)

        if cli.config[:graph]
          if File.directory?(cli.config[:path])
            logger = SandiMeter::Logger.new(data)
            logger.log!(cli.config[:path])

            html_generator = SandiMeter::HtmlGenerator.new
            html_generator.copy_assets!(cli.config[:path])
            html_generator.generate_data!(cli.config[:path])
            html_generator.generate_details!(cli.config[:path], data)

            index_html_path = File.join(cli.config[:path], 'sandi_meter/index.html')
            system "open #{index_html_path}"
          else
            puts "WARNING!!! HTML mode works only if you scan folder."
          end
        end

        config_file_path = File.join(cli.config[:path], 'sandi_meter', 'config.yml')
        config =  if File.exists?(config_file_path)
                    YAML.load(File.read(config_file_path))
                  else
                    { threshold: 90 }
                  end

        if RulesChecker.new(data, config).ok?
          exit 0
        else
          exit 1
        end
      end

      def show_sandi_rules
        puts %(
          1. 100 lines per class
          2. 5 lines per method
          3. 4 params per method call (and don't even try cheating with hash params)
          4. 1 instance variables per controller' action
        )
      end

      private
      def create_config_file(path, relative_path, content)
        file_path = File.join(path, relative_path)
        if File.directory?(path) && !File.exists?(file_path)
          File.open(file_path, "w") do |file|
            file.write(content)
          end
        end
      end

      def version_info
        # stolen from gem 'bubs' :)
        "SandiMeter ".tr('A-Za-z1-90', 'Ⓐ-Ⓩⓐ-ⓩ①-⑨⓪').split('').join(' ') + SandiMeter::VERSION
      end
    end
  end
end
