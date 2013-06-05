require 'ripper'
require_relative 'warning_scanner'

class Analyzer
  attr_reader :classes, :missindented_classes

  def initialize
    @classes = []
    @missindented_classes = []
  end

  def analyze(file_path)
    @file_body = File.read(file_path)
    @indentation_warnings = indentation_warnings

    sexp = Ripper.sexp(@file_body)
    find_class_sexps(sexp)
  end

  private
  def find_class_params(sexp)
    flat_sexp = sexp[1].flatten
    const_indexes = flat_sexp.each_index.select{ |i| flat_sexp[i] == :@const }

    line_number = flat_sexp[const_indexes.first + 2]
    class_name = const_indexes.map { |i| flat_sexp[i + 1] }.join('::')

    [class_name, line_number]
  end

  def find_last_line(class_params)
    class_name, line = class_params

    lines = @file_body.split("\n")
    class_indentation = lines[line - 1].index('class')
    last_line = lines[line..-1].index { |l| l =~ %r(^\s{#{class_indentation}}end$) }

    last_line ? last_line + line + 1 : nil
  end

  def find_class_sexps(sexp)
    sexp.each do |element|
      next unless element.kind_of?(Array)

      if element.first == :class
        class_params = find_class_params(element)

        if @indentation_warnings['class'] && @indentation_warnings['class'].any? { |first_line, last_line| first_line == class_params.last }
          @missindented_classes << class_params
        else
          class_params += [find_last_line(class_params)]
          @classes << class_params
        end
      else
        find_class_sexps(element)
      end
    end
  end

  def indentation_warnings
    warning_scanner = WarningScanner.new
    warning_scanner.scan(@file_body)
  end
end
