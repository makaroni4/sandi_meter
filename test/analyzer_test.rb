require 'test_helper'
require_relative '../lib/analyzer'

describe 'Analyzer' do
  let(:analyzer) { Analyzer.new }

  describe 'finds properly indended classes with lines' do
    let(:test_class) { test_file_path(3) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds indentation warnings for method' do
      analyzer.classes.must_equal [["TestClass", 1]]
      analyzer.missindented_classes.must_equal []
    end
  end

  describe 'finds missindented classes without last line' do
    let(:test_class) { test_file_path(1) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds indentation warnings for method' do
      analyzer.classes.must_equal []
      analyzer.missindented_classes.must_equal [["TestClass", 1]]
    end
  end
end
