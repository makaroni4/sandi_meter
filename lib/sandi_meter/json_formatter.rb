module SandiMeter
  class JsonFormatter
    def print_data(data)
      puts JSON.dump(data)
    end

    def print_log(data)
      puts JSON.dump(data)
    end
  end
end