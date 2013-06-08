require 'ripper'
require_relative 'warning_scanner'

class Analyzer
  attr_reader :classes, :missindented_classes, :methods, :missindented_methods

  def initialize
    @classes = []
    @missindented_classes = []
    @missindented_methods = {}
    @methods = {}
  end

  def analyze(file_path)
    @file_body = File.read(file_path)
    @indentation_warnings = indentation_warnings

    sexp = Ripper.sexp(@file_body)
    scan_sexp(sexp)
  end

  private
  def find_class_params(sexp, current_namespace)
    flat_sexp = sexp[1].flatten
    const_indexes = flat_sexp.each_index.select{ |i| flat_sexp[i] == :@const }

    line_number = flat_sexp[const_indexes.first + 2]
    class_tokens = const_indexes.map { |i| flat_sexp[i + 1] }
    class_tokens.insert(0, current_namespace) unless current_namespace.empty?
    class_name = class_tokens.join('::')

    [class_name, line_number]
  end

  def find_method_params(sexp)
    sexp[1].flatten[1,2]
  end

  def find_last_line(params, token = 'class')
    token_name, line = params

    lines = @file_body.split("\n")
    token_indentation = lines[line - 1].index(token)
    last_line = lines[line..-1].index { |l| l =~ %r(^\s{#{token_indentation}}end$) }

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
        @classes << class_params
      end

      current_namespace = class_params.first
      scan_sexp(element, current_namespace)
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
          @missindented_methods[current_namespace] ||= []
          @missindented_methods[current_namespace] << method_params
        else
          method_params += [find_last_line(method_params, 'def')]
          @methods[current_namespace] ||= []
          @methods[current_namespace] << method_params
        end
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
end
