module SandiMeter
  class Calculator
    def initialize
      @data = {}
      @output = {}
    end

    def push(data)
      data.each_pair do |key, value|
        if value.kind_of?(Array)
          @data[key] ||= []
          @data[key] += value
        elsif value.kind_of?(Hash)
          @data[key] ||= {}
          @data[key].merge!(value)
        end
      end
    end

    def calculate!(store_details = false)
      @store_details = store_details

      check_first_rule
      check_second_rule
      check_third_rule
      check_fourth_rule

      @output
    end

    private
    def log_first_rule
      @output[:first_rule][:log] ||= {}
      @output[:first_rule][:log][:classes] = @data[:classes].inject([]) do |log, class_params|
        # TODO
        # wrap each class params into class and get params with
        # verbose name instead of array keys (class_params[2] should be klass.line_count)
        log << [class_params.first, class_params[2] - class_params[1] - 1, class_params.last] if class_params[-2] == false
        log
      end

      @output[:first_rule][:log][:misindented_classes] = @data[:misindented_classes].inject([]) do |log, class_params|
        log << [class_params.first, nil, class_params.last]
        log
      end
    end

    def log_second_rule
      @output[:second_rule][:log] ||= {}
      @output[:second_rule][:log][:methods] ||= []
      @output[:second_rule][:log][:misindented_methods] ||= []

      @data[:methods].each_pair do |klass, methods|
        methods.select { |m| m[-2] == false }.each do |method_params|
          params = [klass, method_params.first]
          # TODO
          # wrap method param to method class so method_params[1] becomes method.first_line
          # and method_params[2] method.last_line
          params << method_params[2] - method_params[1] - 1
          params << method_params.last

          @output[:second_rule][:log][:methods] << params
        end
      end

      @data[:misindented_methods].each_pair do |klass, methods|
        methods.each do |method_params|
          params = [klass, method_params.first]
          params << nil
          params << method_params.last

          @output[:second_rule][:log][:misindented_methods] << params
        end
      end
    end

    def log_third_rule
      @output[:third_rule][:log] ||={}
      @output[:third_rule][:log][:method_calls] ||= []

      # TODO
      # add name of method being called
      proper_method_calls = @data[:method_calls].inject(0) do |sum, params|
        @output[:third_rule][:log][:method_calls] << params if params.first > 4
      end
    end

    def log_fourth_rule
      @output[:fourth_rule][:log] ||={}
      @output[:fourth_rule][:log][:controllers] ||= []

      @data[:instance_variables].each_pair do |controller, methods|
        methods.each_pair do |method, instance_variables|
          if instance_variables.size > 1
            @output[:fourth_rule][:log][:controllers] << [controller, method, instance_variables]
          end
        end
      end
    end

    def check_first_rule
      total_classes_amount = @data[:classes].size
      small_classes_amount = @data[:classes].inject(0) do |sum, class_params|
        sum += 1 if class_params[-2] == true
        sum
      end

      misindented_classes_amount = @data[:misindented_classes].size

      @output[:first_rule] ||= {}
      @output[:first_rule][:small_classes_amount] = small_classes_amount
      @output[:first_rule][:total_classes_amount] = total_classes_amount
      @output[:first_rule][:misindented_classes_amount] = misindented_classes_amount

      log_first_rule if @store_details
    end

    def check_second_rule
      total_methods_amount = 0
      small_methods_amount = 0

      @data[:methods].each_pair do |klass, methods|
        small_methods_amount += methods.select { |m| m[-2] == true }.size
        total_methods_amount += methods.size
      end

      misindented_methods_amount = 0
      @data[:misindented_methods].each_pair do |klass, methods|
        misindented_methods_amount += methods.size
      end

      @output[:second_rule] ||= {}
      @output[:second_rule][:small_methods_amount] = small_methods_amount
      @output[:second_rule][:total_methods_amount] = total_methods_amount
      @output[:second_rule][:misindented_methods_amount] = misindented_methods_amount

      log_second_rule if @store_details
    end

    # TODO
    # count method definitions argumets too
    def check_third_rule
      total_method_calls = @data[:method_calls].size

      proper_method_calls = @data[:method_calls].inject(0) do |sum, params|
        sum += 1 unless params.first > 4
        sum
      end

      @output[:third_rule] ||= {}
      @output[:third_rule][:proper_method_calls] = proper_method_calls
      @output[:third_rule][:total_method_calls] = total_method_calls

      log_third_rule if @store_details
    end

    def check_fourth_rule
      proper_controllers_amount = 0
      total_controllers_amount = 0

      @data[:instance_variables].each_pair do |controller, methods|
        total_controllers_amount += 1
        proper_controllers_amount += 1 unless methods.values.map(&:size).any? { |v| v > 1 }
      end

      @output[:fourth_rule] ||= {}
      @output[:fourth_rule][:proper_controllers_amount] = proper_controllers_amount
      @output[:fourth_rule][:total_controllers_amount] = total_controllers_amount

      log_fourth_rule if @store_details
    end
  end
end
