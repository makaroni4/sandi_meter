require 'rspec/expectations'

RSpec::Matchers.define :have_attributes do |expected|
  match do |actual|
    result = true
    expected.each do |key, value|
      result = false unless actual.send(key) == value
    end

    result
  end

  failure_message do |actual|
    wrong_fields = {}
    expected.each do |key, value|
      wrong_fields[key] = {
        actual: actual.send(key),
        expected: value
      } unless actual.send(key) == value
    end

    wrong_fields.inject("In #{actual.class.name} ") do |message, wrong_field|
      key, value = wrong_field
      message << "expected that #{key} would be #{value[:expected]}, but was #{value[:actual]}\n"
      message
    end
  end
end
