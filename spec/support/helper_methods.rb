def test_file_path(file_name)
  File.join(
    File.dirname(__FILE__),
    "../test_classes/#{file_name}.rb"
  )
end

def read_test_file(file_name)
  File.read(
    test_file_path(file_name)
  )
end

def load_args_block(method_call)
  loader = ArgsLoader.new
  loader.load(method_call)
end
