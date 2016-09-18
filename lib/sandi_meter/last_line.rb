# Namespace for all SandiMeter modules classes
module SandiMeter
  # Class to calculate last line of given object definition (class, module, method, etc)
  # @author Paul Pettengill (github: prpetten)
  class LastLine
    class << self
      # Finds last line given starting line number, token, and file_lines
      # @note If last line is same as first line, it returns nil
      # @note If last line can not be determined, it returns nil
      # @param start_line_number [Numeric] Starting line number for (class, module, method, etc)
      # @param token [String] start of object definition (eg 'class', 'module', 'def', ect)
      # @param file_lines [Array<String>] each line of file in an array
      # @return [Numeric] Line number for last line of object definition (class, module, method, etc)
      def find(start_line_number, token, file_lines)
        @start_line_number = start_line_number
        @token = token
        @file_lines = file_lines
        determine_last_line
      end

      private

      attr_reader :start_line_number, :token, :file_lines

      def determine_last_line
        return nil if one_liner?
        end_line_index = end_line_at_indent
        return nil if end_line_index.nil?
        last_line_number(end_line_index)
      end

      # @note Since end_line_at_index is the index of ending line offset from start line,
      #   the following must be done to derive the actual last_line_number
      #   1 must be added to account for array index starting at zero
      #   starting_line_number must be added to account for initial offset in remaining lines
      def last_line_number(end_line_index)
        start_line_number + end_line_index + 1
      end

      def token_indentation
        first_line.index(token)
      end

      def one_liner?
        %r(\A\s*#{token}.+end\s*\z) === first_line
      end

      def first_line
        file_lines[start_line_number - 1]
      end

      def end_line_at_indent
        remaining_lines.index do |line|
          line =~ end_at_indent_regex
        end
      end

      def remaining_lines
        file_lines[start_line_number..-1]
      end

      def end_at_indent_regex
        %r(\A\s{#{token_indentation}}end\s*\z)
      end
    end
  end
end
