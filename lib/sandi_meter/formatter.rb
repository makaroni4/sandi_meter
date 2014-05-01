module SandiMeter
  class Formatter
    def print_data(data)
      if data[:first_rule][:total_classes_amount] > 0
        puts "1. #{data[:first_rule][:small_classes_amount] * 100 / data[:first_rule][:total_classes_amount]}% of classes are under 100 lines."
      else
        puts "1. No classes to analyze."
      end

      if data[:second_rule][:total_methods_amount] > 0
        puts "2. #{data[:second_rule][:small_methods_amount] * 100 / data[:second_rule][:total_methods_amount]}% of methods are under 5 lines."
      else
        puts "2. No methods to analyze."
      end

      if data[:third_rule][:total_method_calls] > 0
        puts "3. #{data[:third_rule][:proper_method_calls] * 100 / data[:third_rule][:total_method_calls]}% of method calls accepted are less than 4 parameters."
      else
        puts "3. No method calls to analyze."
      end

      if data[:fourth_rule][:total_controllers_amount] > 0
        puts "4. #{data[:fourth_rule][:proper_controllers_amount] * 100 / data[:fourth_rule][:total_controllers_amount]}% of controllers have one instance variable per action."
      else
        puts "4. No controllers to analyze."
      end

      print_log(data)
    end

    def print_log(data)
      return unless data[:first_rule][:log] || data[:second_rule][:log] || data[:fourth_rule][:log]

      if data[:first_rule][:log][:classes].any?
        puts "\nClasses with 100+ lines"
        print_array_of_arrays [["Class name", "Size", "Path"]] + data[:first_rule][:log][:classes]
      end

      if data[:first_rule][:log][:misindented_classes].any?
        puts "\nMisindented classes"
        print_array_of_arrays [["Class name", "Path"]] + data[:first_rule][:log][:misindented_classes].map { |row| row.delete_at(1); row } # 1 – size, which nil for misindented_classes
      end

      if data[:second_rule][:log][:methods].any?
        puts "\nMethods with 5+ lines"
        print_array_of_arrays [["Class name", "Method name", "Size", "Path"]] + data[:second_rule][:log][:methods]
      end

      if data[:second_rule][:log][:misindented_methods].any?
        puts "\nMisindented methods"
        print_array_of_arrays [["Class name", "Method name", "Path"]] + data[:second_rule][:log][:misindented_methods].map { |row| row.delete_at(2); row } # 2 – size, which nil for misindented_methods
      end

      if data[:third_rule][:log][:method_calls].any?
        puts "\nMethod calls with 4+ arguments"
        print_array_of_arrays [["# of arguments", "Path"]] + data[:third_rule][:log][:method_calls]
      end

      if data[:fourth_rule][:log][:controllers].any?
        puts "\nControllers with 1+ instance variables"
        print_array_of_arrays [["Controller name", "Action name", "Instance variables"]] + data[:fourth_rule][:log][:controllers]
      end
    end

    private
    # TODO
    # sort output by number of lines or any param
    def print_array_of_arrays(nested_array)
      nested_sizes = nested_array.map do |row|
        row.map { |element| element.to_s.size }
      end

      sizes = nested_sizes.transpose.map { |row| row.max }

      nested_array.each do |row|
        line_elements = row.each_with_index.map do |element, index|
          element_string = element.kind_of?(Array) ? element.join(', ') : element.to_s
          element_string.ljust(sizes[index] + 1, ' ')
        end

        puts line_elements.join(' | ').prepend("  ")
      end
    end
  end
end
