module SandiMeter
  class RulesChecker
    attr_reader :broken_rules

    def initialize(data, config)
      @config = config
      @rules = []
      @rules << percentage(data[:first_rule][:small_classes_amount], data[:first_rule][:total_classes_amount])
      @rules << percentage(data[:second_rule][:small_methods_amount], data[:second_rule][:total_methods_amount])
      @rules << percentage(data[:third_rule][:proper_method_calls], data[:third_rule][:total_method_calls])
      @rules << percentage(data[:fourth_rule][:proper_controllers_amount], data[:fourth_rule][:total_controllers_amount])
    end

    def ok?
      @broken_rules ||= []

      @rules.each_with_index do |value, index|
        @broken_rules << (index + 1) if @config[:threshold][index] > value
      end

      @broken_rules.empty?
    end

    def output_broken_rules
      return if @broken_rules.empty?

      puts "\n"
      @broken_rules.each do |rule|
        puts "#{rule} rule is broken."
      end
    end

    private
    def percentage(amount, total)
      total > 0 ? (amount / total.to_f)*100 : 100
    end
  end
end
