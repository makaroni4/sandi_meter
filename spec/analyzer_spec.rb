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
      klass = analyzer.classes.find { |c| c.name == "TestClass" }

      expect(klass).to have_attributes(
        first_line: 1,
        last_line: 5,
        path: test_file_path(3)
      )
    end

    it 'finds methods' do
      method = analyzer.methods["TestClass"].find { |m| m.name == "blah" }

      expect(method).to have_attributes(
        first_line: 2,
        last_line: 4,
        number_of_arguments: 0,
        path: test_file_path(3)
      )
    end

    it 'finds method calls that brakes third rule' do
      method_call = analyzer.method_calls.first

      expect(method_call).to have_attributes(
        first_line: 3,
        number_of_arguments: 5,
        path: test_file_path(3)
      )
    end
  end

  describe 'finds misindented classes without last line' do
    let(:test_class) { test_file_path(1) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds indentation warnings for method' do
      klass = analyzer.classes.find { |c| c.name == "MyApp::TestClass" }

      expect(klass).to have_attributes(
        first_line: 2,
        last_line: nil,
        path: test_file_path(1)
      )
    end

    it 'finds methods' do
      method = analyzer.methods["MyApp::TestClass"].find { |m| m.name == "blah" }

      expect(method).to have_attributes(
        first_line: 3,
        last_line: nil,
        number_of_arguments: 0,
        path: test_file_path(1)
      )
    end
  end

  describe 'finds properly indented classes in one file' do
    let(:test_class) { test_file_path(4) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds classes' do
      klass = analyzer.classes.find { |c| c.name == "FirstTestClass" }

      expect(klass).to have_attributes(
        first_line: 1,
        last_line: 4,
        path: test_file_path(4)
      )

      klass = analyzer.classes.find { |c| c.name == "SecondTestClass" }

      expect(klass).to have_attributes(
        first_line: 6,
        last_line: 9,
        path: test_file_path(4)
      )
    end

    it 'finds methods' do
      method = analyzer.methods["FirstTestClass"].find { |m| m.name == "first_meth" }

      expect(method).to have_attributes(
        first_line: 2,
        last_line: 3,
        number_of_arguments: 1,
        path: test_file_path(4)
      )

      method = analyzer.methods["SecondTestClass"].find { |m| m.name == "second_meth" }

      expect(method).to have_attributes(
        first_line: 7,
        last_line: 8,
        number_of_arguments: 1,
        path: test_file_path(4)
      )
    end
  end

  describe 'finds one liner class' do
    let(:test_class) { test_file_path(5) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds classes' do
      klass = analyzer.classes.find { |c| c.name == "OneLinerClass" }

      expect(klass).to have_attributes(
        first_line: 1,
        last_line: nil,
        path: test_file_path(5)
      )
    end

    it 'finds methods' do
      expect(analyzer.methods).to be_empty
    end
  end

  describe 'finds subclass of a class' do
    let(:test_class) { test_file_path(7) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds class and subclass' do
      klass = analyzer.classes.find { |c| c.name == "MyApp::Blah::User" }
      expect(klass).to have_attributes(
        first_line: 5,
        last_line: 13,
        path: test_file_path(7)
      )

      klass = analyzer.classes.find { |c| c.name == "MyApp::Blah::User::SubUser" }
      expect(klass).to have_attributes(
        first_line: 9,
        last_line: 12,
        path: test_file_path(7)
      )
    end

    it 'finds methods' do
      method = analyzer.methods["MyApp::Blah"].find { |m| m.name == "module_meth" }
      expect(method).to have_attributes(
        first_line: 2,
        last_line: 3,
        number_of_arguments: 0,
        path: test_file_path(7)
      )

      method = analyzer.methods["MyApp::Blah::User"].find { |m| m.name == "class_meth" }
      expect(method).to have_attributes(
        first_line: 6,
        last_line: 7,
        number_of_arguments: 0,
        path: test_file_path(7)
      )

      method = analyzer.methods["MyApp::Blah::User::SubUser"].find { |m| m.name == "sub_meth" }
      expect(method).to have_attributes(
        first_line: 10,
        last_line: 11,
        number_of_arguments: 0,
        path: test_file_path(7)
      )
    end
  end

  describe 'finds class and methods with private methods' do
    let(:test_class) { test_file_path(8) }

    before do
      analyzer.analyze(test_class)
    end

    it 'finds class and subclass' do
      klass = analyzer.classes.find { |c| c.name == "RailsController" }
      expect(klass).to have_attributes(
        first_line: 1,
        last_line: 12,
        path: test_file_path(8)
      )
    end

    it 'finds methods' do
      method = analyzer.methods["RailsController"].find { |m| m.name == "index" }
      expect(method).to have_attributes(
        first_line: 2,
        last_line: 3,
        number_of_arguments: 0,
        path: test_file_path(8)
      )

      method = analyzer.methods["RailsController"].find { |m| m.name == "destroy" }
      expect(method).to have_attributes(
        first_line: 5,
        last_line: 6,
        number_of_arguments: 0,
        path: test_file_path(8)
      )

      method = analyzer.methods["RailsController"].find { |m| m.name == "private_meth" }
      expect(method).to be_nil
    end
  end

  describe 'instance variables in methods' do
    context 'in controller class' do
      let(:test_class) { test_file_path('9_controller') }

      before do
        analyzer.analyze(test_class)
      end

      it 'finds instance variable' do
        method = analyzer.methods["UsersController"].find { |m| m.name == "index" }
        expect(method.ivars).to eq(["@users"])
      end
    end

    context 'in controller class with non instance variables' do
      let(:test_class) { test_file_path('14_controller') }

      before do
        analyzer.analyze(test_class)
      end

      it 'does not find instance variables' do
        method = analyzer.methods["GuestController"].find { |m| m.name == "create_guest_user" }
        expect(method.ivars).to be_empty
      end
    end

    context 'not in controller class' do
      let(:test_class) { test_file_path(10) }

      before do
        analyzer.analyze(test_class)
      end

      it 'does not find instance variable' do
        method = analyzer.methods["User"].find { |m| m.name == "initialize" }
        expect(method.ivars).to be_empty

        method = analyzer.methods["User"].find { |m| m.name == "hi" }
        expect(method.ivars).to be_empty
      end
    end

    context 'in controller class with private method' do
      let(:test_class) { test_file_path("15_controller") }

      before do
        analyzer.analyze(test_class)
      end

      it 'finds method defined after public keyword' do
        method = analyzer.methods["UsersController"].find { |m| m.name == "create" }
        expect(method.ivars).to eq(["@user"])
      end

      it 'omits actions without instance variables' do
        method = analyzer.methods["UsersController"].find { |m| m.name == "show" }
        expect(method.ivars).to be_empty
      end

      it 'omits private methods' do
        method = analyzer.methods["UsersController"].find { |m| m.name == "find_user" }
        expect(method).to be_nil
      end

      it 'omits protected methods' do
        method = analyzer.methods["UsersController"].find { |m| m.name == "protected_find_user" }
        expect(method).to be_nil
      end
    end
  end

  describe 'hash method arguments' do
    let(:test_class) { test_file_path(11) }

    before do
      analyzer.analyze(test_class)
    end

    it 'counts arguments' do
      method_call = analyzer.method_calls.first

      expect(method_call).to have_attributes(
        first_line: 3,
        number_of_arguments: 5,
        path: test_file_path(11)
      )
    end
  end

  describe 'empty lines inside class' do
    let(:test_class) { test_file_path(12) }

    before do
      analyzer.analyze(test_class)
    end

    it 'are count for class definition' do
      klass = analyzer.classes.find { |c| c.name == "Valera" }

      expect(klass).to have_attributes(
        first_line: 1,
        last_line: 109,
        path: test_file_path(12)
      )
    end

    it 'are count for method definition' do
      method = analyzer.methods["Valera"].find { |m| m.name == "doodle" }

      expect(method).to have_attributes(
        first_line: 2,
        last_line: 9,
        number_of_arguments: 0,
        path: test_file_path(12)
      )
    end
  end

  describe 'inline code in class definition' do
    let(:test_class) { test_file_path(13) }

    before do
      analyzer.analyze(test_class)
    end

    it 'is not scanned' do
      expect(analyzer.method_calls).to be_empty
    end
  end

  describe 'analazing complex methods' do
    let(:test_class) { test_file_path(14) }
    let(:methods) { analyzer.methods["TestClass"] }

    before do
      analyzer.analyze(test_class)
    end

    it 'mark 4line methods good' do
      method = analyzer.methods["TestClass"].find { |m| m.name == "render4" }

      expect(method).to have_attributes(
        first_line: 2,
        last_line: 7,
        number_of_arguments: 0,
        path: test_file_path(14)
      )
    end

    it 'mark 5line methods good' do
      method = analyzer.methods["TestClass"].find { |m| m.name == "render5" }

      expect(method).to have_attributes(
        first_line: 9,
        last_line: 15,
        number_of_arguments: 0,
        path: test_file_path(14)
      )
    end

    it 'mark 6line methods bad' do
      method = analyzer.methods["TestClass"].find { |m| m.name == "render6" }

      expect(method).to have_attributes(
        first_line: 17,
        last_line: 24,
        number_of_arguments: 0,
        path: test_file_path(14)
      )
    end
  end
end
