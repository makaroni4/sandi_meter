require 'test_helper'
require_relative '../lib/sandi_meter/rules_checker'

describe SandiMeter::RulesChecker do
  let(:fail_conditions) do
    {
      first_rule:  { small_classes_amount: 1,      total_classes_amount: 2 },
      second_rule: { small_methods_amount: 2,      total_methods_amount: 2 },
      third_rule:  { proper_method_calls: 2,       total_method_calls: 2 },
      fourth_rule: { proper_controllers_amount: 2, total_controllers_amount: 2 }
    }
  end

  let(:succeed_conditions) do
    {
      first_rule:  { small_classes_amount: 2,      total_classes_amount: 2 },
      second_rule: { small_methods_amount: 2,      total_methods_amount: 2 },
      third_rule:  { proper_method_calls: 2,       total_method_calls: 2 },
      fourth_rule: { proper_controllers_amount: 0, total_controllers_amount: 0 }
    }
  end

  describe "#ok?" do
    it "returns false in any of conditions fail" do
      expect(SandiMeter::RulesChecker.new(fail_conditions)).to_not be_ok
    end

    it "returns true if all of conditions succeed" do
      expect(SandiMeter::RulesChecker.new(succeed_conditions)).to be_ok
    end
  end
end
