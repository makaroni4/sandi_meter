require 'test_helper'
require_relative '../lib/sandi_meter/calculator'
require_relative '../lib/sandi_meter/analyzer'

describe SandiMeter::Calculator do
  let(:analyzer) { SandiMeter::Analyzer.new }
  let(:calculator) { SandiMeter::Calculator.new }

  describe 'line number in details' do
    let(:test_class) { test_file_path(15) }

    before do
      data = analyzer.analyze(test_class)
      calculator.push(data)
    end

    it 'counts class lines' do
      output = calculator.calculate!(true)
      klass = output[:first_rule][:log][:classes].find { |params| params.first == "User" }
      klass[1].should eq(109)
    end

    it 'counts method lines' do
      output = calculator.calculate!(true)
      method_params = output[:second_rule][:log][:methods].find { |method| method[1] == "create" }
      method_params[2].should eq(6)
    end
  end

  describe "#log_fourth_rule" do
    context "when there are violations of the fourth rule" do
      let(:test_class) { test_file_path("10_controller") }

      before do
        data = analyzer.analyze(test_class)
        calculator.push(data)
      end

      it "adds the expected entries to the log" do
        output = calculator.calculate!(true)

        fourth_rule_log_entry = output[:fourth_rule][:log][:controllers][0]
        controller_name = fourth_rule_log_entry[0]
        action = fourth_rule_log_entry[1]
        instance_variables = fourth_rule_log_entry[2]

        expect(controller_name).to eq "AnotherUsersController"
        expect(action).to eq "index"
        expect(instance_variables).to include("@users")
        expect(instance_variables).to include("@excess_variable")
        expect(instance_variables.length).to eq 2
      end
    end
    context "when there are no violations of the fourth rule" do
      let(:test_class) { test_file_path("9_controller") }

      before do
        data = analyzer.analyze(test_class)
        calculator.push(data)
      end

      it "does not add any entries to the log" do
        output = calculator.calculate!(true)
        expect(output[:fourth_rule][:log][:controllers]).to eq []
      end
    end
  end

  describe 'no matching ruby files found' do
    it 'counts class lines' do
      output = calculator.calculate!(false)
      output[:first_rule][:total_classes_amount].should eql(0)
    end

    it 'counts method lines' do
      output = calculator.calculate!(true)
      output[:second_rule][:total_methods_amount].should eql(0)
    end
  end
end
