# encoding: utf-8
require 'mixlib/cli'
require 'sandi_meter/file_scanner'
require 'sandi_meter/formatter'
require 'sandi_meter/rules_checker'
require 'sandi_meter/logger'
require 'sandi_meter/version'
require 'sandi_meter/html_generator'
require 'yaml'

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

    option :threshold,
      short: "-t THRESHOLDS",
      long: "--threshold THRESHOLDS",
      description: "To brake CI build you can set percentage threshold for each rule -t 90,90,90,100",
      required: false,
      proc: Proc.new { |t| t.split(",").map(&:to_i) }
  end

  class CLI
    class << self
      def execute
        cli = CommandParser.new
        cli.parse_options

        create_log_folder(cli.config[:path])
        create_config_file(cli.config[:path], 'sandi_meter/.sandi_meter', %w(db vendor).join("\n"))

        #raise cli.config[:threshold].inspect

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

        formatter = SandiMeter::Formatter.new
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

        if cli.config[:threshold]
          raise %(Provide threshould for each rule like this: "90,90,90,90") if cli.config[:threshold].size < 4
          config = { threshold: cli.config[:threshold] }
          create_config_file(cli.config[:path], 'sandi_meter/config.yml', YAML.dump(config))
        else
          config_file_path = File.join(cli.config[:path], 'sandi_meter', 'config.yml')
          config =  if File.exists?(config_file_path)
                      YAML.load(File.read(config_file_path))
                    else
                      { threshold: [90, 90, 90, 90] }
                    end
        end

        rules_checker = RulesChecker.new(data, config)
        if rules_checker.ok?
          exit 0
        else
          rules_checker.output_broken_rules
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
      def create_log_folder(path)
        log_dir_path = File.join(path, 'sandi_meter')
        FileUtils.mkdir(log_dir_path) unless Dir.exists?(log_dir_path)
      end

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
