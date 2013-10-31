require 'open3'

module SandiMeter
  class WarningScanner
    attr_reader :indentation_warnings

    INDENTATION_WARNING_REGEXP = /at 'end' with '(def|class|module)' at (\d+)\z/

    def scan(source)
      status, @warnings, process = if defined? Bundler
                                  Bundler.with_clean_env do
                                       validate(source)
                                    end
                                  else
                                    validate(source)
                                  end

      check_syntax(status)
      @indentation_warnings = parse_warnings
    end

    private
    def validate(source)
      Open3.capture3("#{RUBY_ENGINE} -wc", stdin_data: source)
    end

    def check_syntax(status)
      raise SyntaxError, @warnings unless !!(status =~ /Syntax\sOK/)
    end

    def check_token_lines(token, line_num, end_line_num)
      raise 'No valid end line number' unless end_line_num =~ /^\d+$/
      raise 'No valid line number' unless line_num =~ /^\d+$/
      raise 'No valid token ("def" or "class")' unless token =~ /^def|class|module$/
    end

    def extract_indentation_mismatch(warning_line)
      _, end_line_num, warning_type, warning_body = warning_line.split(':').map(&:strip)
      return nil unless warning_type == 'warning'
      return nil unless warning_body =~ /at 'end' with '(def|class|module)' at (\d+)\z/

      res = warning_body.match(INDENTATION_WARNING_REGEXP)[1..2] << end_line_num
      check_token_lines(*res)

      res
    end

    def parse_warnings
      @warnings.split("\n").inject({}) do |warnings, warning|
        token, line, end_line = extract_indentation_mismatch(warning)
        warnings[token] ||= []
        warnings[token] << [line.to_i, end_line.to_i]
        warnings
      end
    end
  end
end
