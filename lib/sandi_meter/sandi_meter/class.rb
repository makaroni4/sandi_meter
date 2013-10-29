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
      last_line - first_line - 1 if last_line
    end

    def small?
      size <= MAX_LOC if last_line
    end

    def misindented?
      !!(last_line)
    end

    def controller?
      !!(controller)
    end
  end
end
