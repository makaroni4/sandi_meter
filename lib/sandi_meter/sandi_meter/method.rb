module SandiMeter
  class Method
    MAX_LOC = 5

    attr_accessor :name, :misindented, :first_line, :last_line, :path, :number_of_arguments, :ivars

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
      @ivars = []
    end

    def size
      @last_line - @first_line - 1 if @last_line
    end

    def misindented?
      !(@last_line)
    end

    def small?
      size <= MAX_LOC if @last_line
    end
  end
end
