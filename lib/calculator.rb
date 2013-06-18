class Calculator
  def initialize
    @data = {}
  end

  def push(data)
    data.each_pair do |key, value|
      if value.kind_of?(Array)
        @data[key] ||= []
        @data[key] += value
      elsif value.kind_of?(Hash)
        @data[key] ||= {}
        @data[key].merge!(value)
      end
    end
  end

  def calculate

  end
end
