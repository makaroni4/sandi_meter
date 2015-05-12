require 'test_helper'
require_relative '../lib/sandi_meter/warning_scanner'

describe SandiMeter::WarningScanner do
  let(:scanner) { SandiMeter::WarningScanner.new }

  describe 'scanning class with indentation warnings' do
    let(:test_class) { read_test_file(1) }

    before do
      scanner.scan(test_class)
    end

    it 'finds indentation warnings for method' do
      expect(scanner.indentation_warnings['def']).to eq([[3, 4]])
    end

    it 'finds indentation warnings for class' do
      expect(scanner.indentation_warnings['class']).to eq([[2, 5]])
    end

    it 'finds indentation warnings for module' do
      expect(scanner.indentation_warnings['module']).to eq([[1, 6]])
    end
  end

  describe 'scanning class with syntax error' do
    let(:test_class) { read_test_file(2) }

    it 'raise syntax error' do
      expect {
        scanner.scan(test_class)
      }.to raise_error(SyntaxError)
    end
  end
end
