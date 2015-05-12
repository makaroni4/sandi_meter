module SandiMeter
  class RulesChecker
    def initialize(data, config)
      @config = config
      @rules = []
      @rules << percentage(data[:first_rule][:small_classes_amount], data[:first_rule][:total_classes_amount])
      @rules << percentage(data[:second_rule][:small_methods_amount], data[:second_rule][:total_methods_amount])
      @rules << percentage(data[:third_rule][:proper_method_calls], data[:third_rule][:total_method_calls])
      @rules << percentage(data[:fourth_rule][:proper_controllers_amount], data[:fourth_rule][:total_controllers_amount])
    end

    def ok?
      if @config[:threshold]
        puts "DEPRECATION WARNING: sandi_meter threshold will be deprecated. Set thresholds for each rule in sandi_meter config.yml"

        @rules.reduce(:+) / 4 > @config[:threshold]
      elsif @config[:thresholds]
        @rules.each_with_index.map { |percentage, index| percentage >= @config[:thresholds][index].to_f }.reduce(:&)
      end
    end

    private
    def percentage(amount, total)
      total > 0 ? (amount / total.to_f) * 100 : 100
    end
  end
end
