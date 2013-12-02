module SandiMeter
  class Class
    MAX_LOC = 100

    attr_accessor :name, :path, :first_line, :last_line, :controller

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def size
      last_line and (last_line - first_line - 1)
    end

    def small?
      last_line && size <= MAX_LOC
    end

    def misindented?
      !!(last_line)
    end

    def controller?
      !!(path =~ /\w+_controller.rb$/)
    end
  end
end
