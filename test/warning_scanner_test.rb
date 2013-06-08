require 'test_helper'
require_relative '../lib/warning_scanner'

describe 'WarningScanner' do
  let(:scanner) { WarningScanner.new }

  describe 'scanning class with indentation warnings' do
    let(:test_class) { read_test_file(1) }

    before do
      scanner.scan(test_class)
    end

    it 'finds indentation warnings for method' do
      scanner.indentation_warnings['def'].must_equal [[3, 4]]
    end

    it 'finds indentation warnings for class' do
      scanner.indentation_warnings['class'].must_equal [[2, 5]]
    end

    it 'finds indentation warnings for module' do
      scanner.indentation_warnings['module'].must_equal [[1, 6]]
    end
  end

  describe 'scanning class with syntax error' do
    let(:test_class) { read_test_file(2) }

    it 'raise syntax error' do
      assert_raises(SyntaxError) do
        scanner.scan(test_class)
      end
    end
  end
end
