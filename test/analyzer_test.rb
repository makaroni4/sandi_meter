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
      analyzer.classes.must_equal [["TestClass", 1, 4]]
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

  describe 'finds properly indended classes in one file' do
    let(:test_class) { test_file_path(4) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds classes' do
      analyzer.classes.must_include ["FirstTestClass", 1, 4]
      analyzer.classes.must_include ["SecondTestClass", 6, 9]
      analyzer.missindented_classes.must_equal []
    end
  end

  describe 'finds one liner class' do
    let(:test_class) { test_file_path(5) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds classes' do
      analyzer.classes.must_include ["OneLinerClass", 1, nil]
      analyzer.missindented_classes.must_equal []
    end
  end
end
