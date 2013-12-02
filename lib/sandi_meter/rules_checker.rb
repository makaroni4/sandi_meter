module SandiMeter
  class RulesChecker
    def initialize(data)
      @rules = []
      @rules << data[:first_rule][:small_classes_amount]       / data[:first_rule][:total_classes_amount]
      @rules << data[:second_rule][:small_methods_amount]      / data[:second_rule][:total_methods_amount]
      @rules << data[:third_rule][:proper_method_calls]        / data[:third_rule][:total_method_calls]
      @rules << data[:fourth_rule][:proper_controllers_amount] / data[:fourth_rule][:total_controllers_amount]
    end
    
    def ok?
      @rules.all? { |rule| rule == 1 }
    end
  end
end
