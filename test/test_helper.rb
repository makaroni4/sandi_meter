require 'minitest/autorun'

def read_test_file file_name
  File.read(
    File.join(
      File.dirname(__FILE__),
      "test_classes/#{file_name}.rb"
    )
  )
end
