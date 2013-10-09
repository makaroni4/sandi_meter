require 'test_helper'
require_relative '../lib/sandi_meter/analyzer'

describe SandiMeter::Analyzer do
  let(:analyzer) { SandiMeter::Analyzer.new }

  describe 'properly indented classes with lines' do
    let(:test_class) { test_file_path(3) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds indentation warnings for method' do
      analyzer.classes.should eq([["TestClass", 1, 5, true, "#{test_file_path(3)}:1"]])
      analyzer.misindented_classes.should be_empty
    end

    it 'finds methods' do
      analyzer.methods.should eq({"TestClass"=>[["blah", 2, 4, 0, true, "#{test_file_path(3)}:2"]]})
      analyzer.misindented_methods.should be_empty
    end

    it 'finds method calls that brakes third rule' do
      analyzer.method_calls.should eq([[5, "#{test_file_path(3)}:3"]])
    end
  end

  describe 'finds misindented classes without last line' do
    let(:test_class) { test_file_path(1) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds indentation warnings for method' do
      analyzer.classes.should be_empty
      analyzer.misindented_classes.should eq([["MyApp::TestClass", 2, nil, "#{test_file_path(1)}:2"]])
    end

    it 'finds methods' do
      analyzer.methods.should be_empty
      analyzer.misindented_methods.should eq({"MyApp::TestClass"=>[["blah", 3, nil, 0, "#{test_file_path(1)}:3"]]})
    end
  end

  describe 'finds properly indented classes in one file' do
    let(:test_class) { test_file_path(4) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds classes' do
      analyzer.classes.should include(["FirstTestClass", 1, 4, true, "#{test_file_path(4)}:1"])
      analyzer.classes.should include(["SecondTestClass", 6, 9, true, "#{test_file_path(4)}:6"])
      analyzer.misindented_classes.should be_empty
    end

    it 'finds methods' do
      analyzer.methods["FirstTestClass"].should eq([["first_meth", 2, 3, 1, true, "#{test_file_path(4)}:2"]])
      analyzer.methods["SecondTestClass"].should eq([["second_meth", 7, 8, 1, true, "#{test_file_path(4)}:7"]])
      analyzer.misindented_methods.should be_empty
    end
  end

  describe 'finds one liner class' do
    let(:test_class) { test_file_path(5) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds classes' do
      analyzer.misindented_classes.should eq([["OneLinerClass", 1, nil, "#{test_file_path(5)}:1"]])
      analyzer.classes.should be_empty
    end

    it 'finds methods' do
      analyzer.methods.should be_empty
      analyzer.misindented_methods.should be_empty
    end
  end

  describe 'finds subclass of a class' do
    let(:test_class) { test_file_path(7) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds class and subclass' do
      analyzer.classes.should include(["MyApp::Blah::User", 5, 13, true, "#{test_file_path(7)}:5"])
      analyzer.classes.should include(["MyApp::Blah::User::SubUser", 9, 12, true, "#{test_file_path(7)}:9"])
      analyzer.misindented_classes.should be_empty
    end

    it 'finds methods' do
      analyzer.methods["MyApp::Blah"].should eq([["module_meth", 2, 3, 0, true, "#{test_file_path(7)}:2"]])
      analyzer.methods["MyApp::Blah::User"].should eq([["class_meth", 6, 7, 0, true, "#{test_file_path(7)}:6"]])
      analyzer.methods["MyApp::Blah::User::SubUser"].should eq([["sub_meth", 10, 11, 0, true, "#{test_file_path(7)}:10"]])
      analyzer.misindented_methods.should be_empty
    end
  end

  describe 'finds class and methods with private methods' do
    let(:test_class) { test_file_path(8) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds class and subclass' do
      analyzer.classes.should include(["RailsController", 1, 12, true, "#{test_file_path(8)}:1"])
      analyzer.misindented_classes.should be_empty
    end

    it 'finds methods' do
      analyzer.methods["RailsController"].should include(["index", 2, 3, 0, true, "#{test_file_path(8)}:2"])
      analyzer.methods["RailsController"].should include(["destroy", 5, 6, 0, true, "#{test_file_path(8)}:5"])
      analyzer.methods["RailsController"].should include(["private_meth", 9, 10, 0, true, "#{test_file_path(8)}:9"])
      analyzer.misindented_methods.should be_empty
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

    context 'in controller class with non instance variables' do
      let(:test_class) { test_file_path('14_controller') }

      before do
        analyzer.analyze(test_class)
      end

      it 'does not find instance variables' do
        analyzer.instance_variables.should eq({"GuestController"=>{"create_guest_user"=>[]}})
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

    context 'in controller class with private method' do
      let(:test_class) { test_file_path("15_controller") }

      before do
        analyzer.analyze(test_class)
      end

      it 'finds method defined after public keyword' do
        analyzer.instance_variables["UsersController"].should have_key("create")
      end

      it 'omits actions without instance variables' do
        analyzer.instance_variables["UsersController"].should_not have_key("show")
      end

      it 'omits private methods' do
        analyzer.instance_variables["UsersController"].should_not have_key("find_user")
      end

      it 'omits protected methods' do
        analyzer.instance_variables["UsersController"].should_not have_key("protected_find_user")
      end


    end
  end

  describe 'hash method arguments' do
    let(:test_class) { test_file_path(11) }

    before do
      analyzer.analyze(test_class)
    end

    it 'counts arguments' do
      analyzer.method_calls.should eq([[5, "#{test_file_path(11)}:3"]])
    end
  end

  describe 'empty lines inside class' do
    let(:test_class) { test_file_path(12) }

    before do
      analyzer.analyze(test_class)
    end

    it 'are count for class definition' do
      analyzer.classes.should eq([["Valera", 1, 109, false, "#{test_file_path(12)}:1"]])
    end

    it 'are count for method definition' do
      analyzer.methods.should eq({"Valera"=>[["doodle", 2, 9, 0, false, "#{test_file_path(12)}:2"]]})
    end
  end

  describe 'inline code in class definition' do
    let(:test_class) { test_file_path(13) }

    before do
      analyzer.analyze(test_class)
    end

    it 'is not scanned' do
      analyzer.method_calls.should be_empty
    end
  end

  describe 'analazing complex methods' do
    let(:test_class) { test_file_path(14) }
    let(:methods) { analyzer.methods["TestClass"] }

    before do
      analyzer.analyze(test_class)
    end

    it 'mark 4line methods good' do
      methods.should include(["render4", 2, 7, 0, true, "#{test_file_path(14)}:2"])
    end

    it 'mark 5line methods good' do
      methods.should include(["render5", 9, 15, 0, true, "#{test_file_path(14)}:9"])
    end

    it 'mark 6line methods bad' do
      methods.should include(["render6", 17, 24, 0, false, "#{test_file_path(14)}:17"])
    end
  end
end
