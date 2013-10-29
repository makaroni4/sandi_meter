module SandiMeter
  class MethodCall
    attr_accessor :path, :number_of_arguments, :first_line

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end
