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
end
