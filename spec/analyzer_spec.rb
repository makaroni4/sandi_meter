require 'test_helper'
require_relative '../lib/analyzer'

describe Analyzer do
  let(:analyzer) { Analyzer.new }

  describe 'finds properly indended classes with lines' do
    let(:test_class) { test_file_path(3) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds indentation warnings for method' do
      analyzer.classes.should eq([["TestClass", 1, 4]])
      analyzer.missindented_classes.should be_empty
    end

    it 'finds methods' do
      analyzer.methods.should eq({"TestClass"=>[["blah", 2, 3, 0]]})
      analyzer.missindented_methods.should be_empty
    end
  end

  describe 'finds missindented classes without last line' do
    let(:test_class) { test_file_path(1) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds indentation warnings for method' do
      analyzer.classes.should be_empty
      analyzer.missindented_classes.should eq([["MyApp::TestClass", 2, nil]])
    end

    it 'finds methods' do
      analyzer.methods.should be_empty
      analyzer.missindented_methods.should eq({"MyApp::TestClass"=>[["blah", 3, nil, 0]]})
    end
  end

  describe 'finds properly indended classes in one file' do
    let(:test_class) { test_file_path(4) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds classes' do
      analyzer.classes.should include(["FirstTestClass", 1, 4])
      analyzer.classes.should include(["SecondTestClass", 6, 9])
      analyzer.missindented_classes.should be_empty
    end

    it 'finds methods' do
      analyzer.methods["FirstTestClass"].should eq([["first_meth", 2, 3, 1]])
      analyzer.methods["SecondTestClass"].should eq([["second_meth", 7, 8, 1]])
      analyzer.missindented_methods.should be_empty
    end
  end

  describe 'finds one liner class' do
    let(:test_class) { test_file_path(5) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds classes' do
      analyzer.missindented_classes.should eq([["OneLinerClass", 1, nil]])
      analyzer.classes.should be_empty
    end

    it 'finds methods' do
      analyzer.methods.should be_empty
      analyzer.missindented_methods.should be_empty
    end
  end

  describe 'finds subclass of a class' do
    let(:test_class) { test_file_path(7) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds class and subclass' do
      analyzer.classes.should include(["MyApp::Blah::User", 5, 13])
      analyzer.classes.should include(["MyApp::Blah::User::SubUser", 9, 12])
      analyzer.missindented_classes.should be_empty
    end

    it 'finds methods' do
      analyzer.methods["MyApp::Blah"].should eq([["module_meth", 2, 3, 0]])
      analyzer.methods["MyApp::Blah::User"].should eq([["class_meth", 6, 7, 0]])
      analyzer.methods["MyApp::Blah::User::SubUser"].should eq([["sub_meth", 10, 11, 0]])
      analyzer.missindented_methods.should be_empty
    end
  end

  describe 'finds class and methods with private methods' do
    let(:test_class) { test_file_path(8) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds class and subclass' do
      analyzer.classes.should include(["RailsController", 1, 12])
      analyzer.missindented_classes.should be_empty
    end

    it 'finds methods' do
      analyzer.methods["RailsController"].should include(["index", 2, 3, 0])
      analyzer.methods["RailsController"].should include(["destroy", 5, 6, 0])
      analyzer.methods["RailsController"].should include(["private_meth", 9, 10, 0])
      analyzer.missindented_methods.should be_empty
    end
  end
end
