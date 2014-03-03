require 'test_helper'
require_relative '../lib/sandi_meter/rules_checker'

describe SandiMeter::RulesChecker do
  let(:conditions) do
    {
      first_rule:  { small_classes_amount: 1,      total_classes_amount: 2 },
      second_rule: { small_methods_amount: 2,      total_methods_amount: 2 },
      third_rule:  { proper_method_calls: 2,       total_method_calls: 2 },
      fourth_rule: { proper_controllers_amount: 2, total_controllers_amount: 2 }
    }
  end

  describe "#ok?" do
    it "returns false with 100 threshold" do
      checker = SandiMeter::RulesChecker.new(conditions, {threshold: [100, 100, 100, 100]})

      expect(checker).to_not be_ok
      expect(checker.broken_rules).to eq([1])
    end

    it "returns true with threshold less than 100" do
      checker = SandiMeter::RulesChecker.new(conditions, {threshold: [50, 50, 50, 50]})

      expect(checker).to be_ok
      expect(checker.broken_rules).to be_empty
    end
  end
end
