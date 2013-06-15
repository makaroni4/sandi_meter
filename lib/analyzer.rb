require 'ripper'
require_relative 'warning_scanner'
require_relative 'loc_checker'

class Analyzer
  attr_reader :classes, :missindented_classes, :methods, :missindented_methods, :method_calls, :instance_variables

  def initialize
    @classes = []
    @missindented_classes = []
    @missindented_methods = {}
    @methods = {}
    @method_calls = []
    @instance_variables = {}
  end

  def analyze(file_path)
    @file_path = file_path
    @file_body = File.read(file_path)
    @file_lines = @file_body.split(/$/).map { |l| l.gsub("\n", '')}
    @indentation_warnings = indentation_warnings

    sexp = Ripper.sexp(@file_body)
    scan_sexp(sexp)

    check_loc
  end

  private
  def check_loc
    loc_checker = LOCChecker.new(@file_lines)
    @classes.each do |klass_params|
      puts "#{klass_params.first} breaks first rule" unless loc_checker.check(klass_params, 'class')
    end

    @methods.each_pair do |klass, methods|
      methods.each do |method_params|
        puts "#{klass}##{method_params.first} breakes second rule" unless loc_checker.check(method_params, 'def')
      end
    end
  end

  def find_class_params(sexp, current_namespace)
    flat_sexp = sexp[1].flatten
    const_indexes = flat_sexp.each_index.select{ |i| flat_sexp[i] == :@const }

    line_number = flat_sexp[const_indexes.first + 2]
    class_tokens = const_indexes.map { |i| flat_sexp[i + 1] }
    class_tokens.insert(0, current_namespace) unless current_namespace.empty?
    class_name = class_tokens.join('::')

    [class_name, line_number]
  end

  # MOVE
  # to method scanner class
  def number_of_arguments(method_sexp)
    arguments = method_sexp[2]
    arguments = arguments[1] if arguments.first == :paren

    arguments[1] == nil ? 0 : arguments[1].size
  end

  def find_method_params(sexp)
    sexp[1].flatten[1,2]
  end

  def find_last_line(params, token = 'class')
    token_name, line = params

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
      module_params += [find_last_line(module_params, 'module')]
      current_namespace = module_params.first

      scan_sexp(element, current_namespace)
    when :class
      class_params = find_class_params(element, current_namespace)

      if @indentation_warnings['class'] && @indentation_warnings['class'].any? { |first_line, last_line| first_line == class_params.last }
        class_params << nil
        @missindented_classes << class_params
      else
        class_params += [find_last_line(class_params)]

        # in case of one liner class last line will be nil
        (class_params.last == nil ? @missindented_classes : @classes) << class_params
      end

      current_namespace = class_params.first
      scan_sexp(element, current_namespace)
    end
  end

  def find_args_add_block(method_call_sexp)
    return unless method_call_sexp.kind_of?(Array)

    method_call_sexp.each do |sexp|
      next unless sexp.kind_of?(Array)

      if sexp.first == :args_add_block
        if sexp[1].size > 4
          argument_lines = sexp[1].map(&:last).map(&:first).uniq.sort
          @method_calls << argument_lines
        end

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
        @instance_variables[current_namespace] ||= {}
        @instance_variables[current_namespace][method_name] ||= []
        @instance_variables[current_namespace][method_name] << sexp[1][1][1]
      else
        scan_def_for_ivars(current_namespace, method_name, sexp)
      end
    end
  end

  def scan_sexp(sexp, current_namespace = '')
    sexp.each do |element|
      next unless element.kind_of?(Array)

      case element.first
      when :def
        method_params = find_method_params(element)
        if @indentation_warnings['def'] && @indentation_warnings['def'].any? { |first_line, last_line| first_line == method_params.last }
          method_params << nil
          method_params << number_of_arguments(element)
          @missindented_methods[current_namespace] ||= []
          @missindented_methods[current_namespace] << method_params
        else
          method_params += [find_last_line(method_params, 'def')]
          method_params << number_of_arguments(element)
          @methods[current_namespace] ||= []
          @methods[current_namespace] << method_params
        end
        scan_def_for_ivars(current_namespace, method_params.first, element) if controller?(current_namespace)
        find_args_add_block(element)
      when :module, :class
        scan_class_sexp(element, current_namespace)
      else
        scan_sexp(element, current_namespace)
      end
    end
  end

  def indentation_warnings
    warning_scanner = WarningScanner.new
    warning_scanner.scan(@file_body)
  end

  def controller?(class_name)
    !!(File.basename(@file_path) =~ /_controller.rb$/) && !!(class_name =~ /Controller$/)
  end
end
