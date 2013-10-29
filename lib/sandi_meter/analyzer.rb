require 'ripper'
require_relative 'warning_scanner'
require_relative 'loc_checker'
require_relative 'method_arguments_counter'
require_relative 'sandi_meter/class'
require_relative 'sandi_meter/method_call'
require_relative 'sandi_meter/method'

module SandiMeter
  class Analyzer
    attr_accessor :parent_token, :private_or_protected
    attr_reader :classes, :methods, :method_calls

    def initialize
      @classes = []
      @methods = {}
      @method_calls = []
    end

    def analyze(file_path)
      @file_path = file_path
      @file_body = File.read(file_path)
      @file_lines = @file_body.split(/$/).map { |l| l.gsub("\n", '') }
      @indentation_warnings = indentation_warnings
      # TODO
      # add better determination wheter file is controller
      @controller = !!(file_path =~ /\w+_controller.rb$/)

      sexp = Ripper.sexp(@file_body)
      scan_sexp(sexp)

      output
    end

    private
    def output
      loc_checker = SandiMeter::LOCChecker.new(@file_lines)

      {
        classes: @classes,
        misindented_classes: @misindented_classes,
        methods: @methods,
        misindented_methods: @misindented_methods,
        method_calls: @method_calls,
        instance_variables: @instance_variables
      }
    end

    def find_class_params(sexp, current_namespace)
      flat_sexp = sexp[1].flatten
      const_indexes = flat_sexp.each_index.select{ |i| flat_sexp[i] == :@const }

      line_number = flat_sexp[const_indexes.first + 2]
      class_tokens = const_indexes.map { |i| flat_sexp[i + 1] }
      class_tokens.insert(0, current_namespace) unless current_namespace.empty?
      class_name = class_tokens.join('::')

      {
        name: class_name,
        first_line: line_number,
        path: @file_path
      }
    end

    # MOVE
    # to method scanner class
    def number_of_arguments(method_sexp)
      arguments = method_sexp[2]
      arguments = arguments[1] if arguments.first == :paren

      arguments[1] == nil ? 0 : arguments[1].size
    end

    def find_method_params(sexp)
      name, first_line = sexp[1].flatten[1, 2]
      {
        name: name,
        first_line: first_line,
        path: @file_path
      }
    end

    def find_last_line(line, token = 'class')
      token_indentation = @file_lines[line - 1].index(token)
      # TODO
      # add check for trailing spaces
      last_line = @file_lines[line..-1].index { |l| l =~ %r(\A\s{#{token_indentation}}end\s*\z) }

      last_line ? last_line + line + 1 : nil
    end

    def scan_class_sexp(element, current_namespace = '')
      case element.first
      when :module
        module_params = find_class_params(element, current_namespace)

        module_params[:last_line] = find_last_line(module_params[:first_line], 'module')
        current_namespace = module_params[:name]

        scan_sexp(element, current_namespace)
      when :class
        class_params = find_class_params(element, current_namespace)

        unless @indentation_warnings['class'] && @indentation_warnings['class'].any? { |first_line, last_line| first_line == class_params[:first_line] }
          class_params[:last_line] = find_last_line(class_params[:first_line])
        end

        @classes << SandiMeter::Class.new(class_params)

        current_namespace = class_params[:name]
        scan_sexp(element, current_namespace)
      end
    end

    def find_args_add_block(method_call_sexp)
      return unless method_call_sexp.kind_of?(Array)

      method_call_sexp.each do |sexp|
        next unless sexp.kind_of?(Array)

        if sexp.first == :args_add_block
          counter = SandiMeter::MethodArgumentsCounter.new
          arguments_count, line = counter.count(sexp)

          @method_calls << SandiMeter::MethodCall.new(
            path: @file_path,
            first_line: line,
            number_of_arguments: arguments_count
          )

          find_args_add_block(sexp)
        else
          find_args_add_block(sexp)
        end
      end
    end

    def scan_def_for_ivars(current_namespace, method_name, method_sexp)
      return unless method_sexp.kind_of?(Array)

      method_sexp.each do |sexp|
        next unless sexp.kind_of?(Array)

        if sexp.first == :assign
          method = @methods[current_namespace].find { |m| m.name == method_name }
          method.ivars << sexp[1][1][1] if sexp[1][1][0] == :@ivar
        else
          scan_def_for_ivars(current_namespace, method_name, sexp)
        end
      end
    end

    def scan_sexp(sexp, current_namespace = '')
      sexp.each do |element|
        next unless element.kind_of?(Array)

        @parent_token = element.first
        case element.first
        when :def
          method_params = find_method_params(element)
          method_params[:number_of_arguments] = number_of_arguments(element)
          unless @indentation_warnings['def'] && @indentation_warnings['def'].any? { |first_line, last_line| first_line == method_params[:first_line] }
            method_params[:last_line] = find_last_line(method_params[:first_line], 'def')
          end

          @methods[current_namespace] ||= []
          @methods[current_namespace] << SandiMeter::Method.new(method_params) unless @private_or_protected

          if @controller && !@private_or_protected
            scan_def_for_ivars(current_namespace, method_params[:name], element)
          end

          find_args_add_block(element)
        when :module, :class
          scan_class_sexp(element, current_namespace)
        when :vcall
          if element[1].first == :@ident
            case element[1][1]
            when "private"
              @private_or_protected = true
            when "public"
              @private_or_protected = false
            else
              scan_sexp(element, current_namespace)
            end
          else
            scan_sexp(element, current_namespace)
          end
        else
          scan_sexp(element, current_namespace)
        end
      end
    end

    def indentation_warnings
      warning_scanner = SandiMeter::WarningScanner.new
      warning_scanner.scan(@file_body)
    end
  end
end
