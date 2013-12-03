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
      @output[:first_rule][:log][:classes] = @data[:classes].inject([]) do |log, klass|
        log << [klass.name, klass.size, klass.path] if klass.last_line && !klass.small?
        log
      end

      @output[:first_rule][:log][:misindented_classes] = @data[:classes].select { |c| c.last_line.nil? }.inject([]) do |log, klass|
        log << [klass.name, nil, klass.path]
        log
      end
    end

    def log_second_rule
      @output[:second_rule][:log] ||= {}
      @output[:second_rule][:log][:methods] ||= []
      @output[:second_rule][:log][:misindented_methods] ||= []

      @data[:methods].each_pair do |klass, methods|
        methods.select { |m| !m.misindented? && !m.small? }.each do |method|
          @output[:second_rule][:log][:methods] << [klass, method.name, method.size, method.path]
        end
      end

      @data[:methods].each_pair do |klass, methods|
        methods.each do |method|
          next unless method.misindented?

          @output[:second_rule][:log][:misindented_methods] << [klass, method.name, method.size, method.path]
        end
      end
    end

    def log_third_rule
      @output[:third_rule][:log] ||={}
      @output[:third_rule][:log][:method_calls] ||= []

      # TODO
      # add name of method being called
      proper_method_calls = @data[:method_calls].inject(0) do |sum, method_call|
        @output[:third_rule][:log][:method_calls] << [method_call.number_of_arguments, method_call.path] if method_call.number_of_arguments > 4
      end
    end

    def log_fourth_rule
      @output[:fourth_rule][:log] ||={}
      @output[:fourth_rule][:log][:controllers] ||= []

      @data[:classes].select { |c| c.controller }.each do |klass|
        @data[:methods][klass].each do |method|
          next if method.ivars.empty?

          @output[:fourth_rule][:log][:controllers] << [klass.name, method.name, method.ivars]
        end
      end
    end

    def check_first_rule
      total_classes_amount = @data[:classes].size
      small_classes_amount = @data[:classes].select(&:small?).size

      misindented_classes_amount = @data[:classes].select { |c| c.last_line.nil? }

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
        small_methods_amount += methods.select { |m| m.small? }.size
        total_methods_amount += methods.size
      end

      misindented_methods_amount = 0
      @data[:methods].each_pair do |klass, methods|
        misindented_methods_amount += methods.select { |m| m.last_line.nil? }.size
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

      proper_method_calls = @data[:method_calls].inject(0) do |sum, method_call|
        sum += 1 unless method_call.number_of_arguments > 4
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

      @data[:classes].select { |c| c.controller? }.each do |klass|
        total_controllers_amount += 1
        proper_controllers_amount += 1 unless @data[:methods][klass.name] && @data[:methods][klass.name].select { |m| m.ivars.uniq.size > 1 }.any?
      end

      @output[:fourth_rule] ||= {}
      @output[:fourth_rule][:proper_controllers_amount] = proper_controllers_amount
      @output[:fourth_rule][:total_controllers_amount] = total_controllers_amount

      log_fourth_rule if @store_details
    end
  end
end
