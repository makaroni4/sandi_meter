module SandiMeter
  class Formatter
    def print_data(data)
      if data[:first_rule][:total_classes_amount] > 0
        puts "1. #{data[:first_rule][:small_classes_amount] * 100 / data[:first_rule][:total_classes_amount]}% of classes are under 100 lines."
      else
        puts "1. No classes to analize."
      end

      if data[:second_rule][:total_methods_amount] > 0
        puts "2. #{data[:second_rule][:small_methods_amount] * 100 / data[:second_rule][:total_methods_amount]}% of methods are under 5 lines."
      else
        puts "2. No methods to analize."
      end

      if data[:third_rule][:total_method_calls] > 0
        puts "3. #{data[:third_rule][:proper_method_calls] * 100 / data[:third_rule][:total_method_calls]}% of methods calls accepts are less than 4 parameters."
      else
        puts "3. No method calls to analize."
      end

      if data[:fourth_rule][:total_controllers_amount] > 0
        puts "4. #{data[:fourth_rule][:proper_controllers_amount] * 100 / data[:fourth_rule][:total_controllers_amount]}% of controllers have one instance variable per action."
      else
        puts "4. No controllers to analize."
      end
    end
  end
end
