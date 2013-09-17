class Calculator
  def initialize
    @data = {}
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

  def calculate!
    check_first_rule
    check_second_rule
    check_third_rule
    check_fourth_rule
  end

  private
  def check_first_rule
    total_classes_amount = @data[:classes].size
    small_classes_amount = @data[:classes].inject(0) do |sum, class_params|
      sum += 1 if class_params.last == true
      sum
    end
    missindented_classes_amount = @data[:missindented_classes].size

    puts "#{small_classes_amount * 100/ total_classes_amount}% of classes are under 100 lines."

    # TODO uncomment when missindented location will be implemented
    #
    # if missindented_classes_amount > 0
    #   puts "Pay attention to #{missindented_classes_amount} missindented classes."
    # end
  end

  def check_second_rule
    total_methods_amount = 0
    small_methods_amount = 0

    @data[:methods].each_pair do |klass, methods|
      small_methods_amount += methods.select { |m| m.last == true }.size
      total_methods_amount += methods.size
    end

    missindented_methods_amount = 0
    @data[:missindented_methods].each_pair do |klass, methods|
      missindented_methods_amount += methods.size
    end

    puts "#{small_methods_amount * 100 / total_methods_amount}% of methods are under 5 lines."

    # TODO uncomment when missindented location will be implemented
    #
    # if missindented_methods_amount > 0
    #   puts "Pay attention to #{missindented_methods_amount} missindented methods."
    # end
  end

  # TODO
  # count method definitions argumets too
  def check_third_rule
    total_method_calls = @data[:method_calls].size

    proper_method_calls = @data[:method_calls].inject(0) do |sum, params|
      sum += 1 unless params.first > 4
      sum
    end

    missindented_methods_amount = 0
    @data[:missindented_methods].each_pair do |klass, methods|
      missindented_methods_amount += methods.size
    end

    if total_method_calls > 0
      puts "#{proper_method_calls * 100 / total_method_calls}% of methods calls accepts are less than 4 parameters."
    else
      puts "Seems like there no method calls. WAT?!"
    end
  end

  def check_fourth_rule
    proper_controllers_amount = 0
    total_controllers_amount = 0

    @data[:instance_variables].each_pair do |controller, methods|
      total_controllers_amount += 1
      proper_controllers_amount += 1 unless methods.values.map(&:size).any? { |v| v > 1 }
    end

    if total_controllers_amount > 0
      puts "#{proper_controllers_amount * 100 / total_controllers_amount}% of controllers have one instance variable per action."
    else
      puts "Seems like there are no controllers :)"
    end
  end
end
