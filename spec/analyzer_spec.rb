require 'test_helper'
require_relative '../lib/sandi_meter/analyzer'

describe SandiMeter::Analyzer do
  let(:analyzer) { SandiMeter::Analyzer.new }

  describe 'finds properly indended classes with lines' do
    let(:test_class) { test_file_path(3) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds indentation warnings for method' do
      analyzer.classes.should eq([["TestClass", 1, 5, true]])
      analyzer.missindented_classes.should be_empty
    end

    it 'finds methods' do
      analyzer.methods.should eq({"TestClass"=>[["blah", 2, 4, 0, true]]})
      analyzer.missindented_methods.should be_empty
    end

    it 'finds method calls that brakes third rule' do
      analyzer.method_calls.should eq([[5,3]])
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
      analyzer.classes.should include(["FirstTestClass", 1, 4, true])
      analyzer.classes.should include(["SecondTestClass", 6, 9, true])
      analyzer.missindented_classes.should be_empty
    end

    it 'finds methods' do
      analyzer.methods["FirstTestClass"].should eq([["first_meth", 2, 3, 1, true]])
      analyzer.methods["SecondTestClass"].should eq([["second_meth", 7, 8, 1, true]])
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
      analyzer.classes.should include(["MyApp::Blah::User", 5, 13, true])
      analyzer.classes.should include(["MyApp::Blah::User::SubUser", 9, 12, true])
      analyzer.missindented_classes.should be_empty
    end

    it 'finds methods' do
      analyzer.methods["MyApp::Blah"].should eq([["module_meth", 2, 3, 0, true]])
      analyzer.methods["MyApp::Blah::User"].should eq([["class_meth", 6, 7, 0, true]])
      analyzer.methods["MyApp::Blah::User::SubUser"].should eq([["sub_meth", 10, 11, 0, true]])
      analyzer.missindented_methods.should be_empty
    end
  end

  describe 'finds class and methods with private methods' do
    let(:test_class) { test_file_path(8) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds class and subclass' do
      analyzer.classes.should include(["RailsController", 1, 12, true])
      analyzer.missindented_classes.should be_empty
    end

    it 'finds methods' do
      analyzer.methods["RailsController"].should include(["index", 2, 3, 0, true])
      analyzer.methods["RailsController"].should include(["destroy", 5, 6, 0, true])
      analyzer.methods["RailsController"].should include(["private_meth", 9, 10, 0, true])
      analyzer.missindented_methods.should be_empty
    end
  end

  describe 'instance variables in methods' do
    context 'in controller class' do
      let(:test_class) { test_file_path('9_controller') }

      before do
        analyzer.analyze(test_class)
      end

      it 'finds instance variable' do
        analyzer.instance_variables.should eq({"UsersController"=>{"index"=>["@users"]}})
      end
    end

    context 'not in controller class' do
      let(:test_class) { test_file_path(10) }

      before do
        analyzer.analyze(test_class)
      end

      it 'does not find instance variable' do
        analyzer.instance_variables.should be_empty
      end
    end
  end

  describe 'hash method arguments' do
    let(:test_class) { test_file_path(11) }

    before do
      analyzer.analyze(test_class)
    end

    it 'counts arguments' do
      analyzer.method_calls.should eq([[5, 3]])
    end
  end
end
