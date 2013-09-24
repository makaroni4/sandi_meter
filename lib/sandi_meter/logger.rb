require 'fileutils'

module SandiMeter
  class Logger
    def log!(path, data)
      log_dir_path = File.join(path, 'sandi_meter')
      FileUtils.mkdir(log_dir_path) unless Dir.exists?(log_dir_path)

      File.open(File.join(log_dir_path, 'sandi_meter.log'), 'a') do |file|
        file.puts(log_line(data))
      end
    end

    private
    def log_line(data)
      log_line_data = []
      log_line_data << data[:first_rule][:small_classes_amount]
      log_line_data << data[:first_rule][:total_classes_amount] - data[:first_rule][:small_classes_amount]

      log_line_data << data[:second_rule][:small_methods_amount]
      log_line_data << data[:second_rule][:total_methods_amount] - data[:second_rule][:small_methods_amount]

      log_line_data << data[:third_rule][:proper_method_calls]
      log_line_data << data[:third_rule][:total_method_calls] - data[:third_rule][:proper_method_calls]

      log_line_data << data[:fourth_rule][:proper_controllers_amount]
      log_line_data << data[:fourth_rule][:total_controllers_amount] - data[:fourth_rule][:proper_controllers_amount]

      log_line_data << Time.now.to_i

      log_line_data.join(';')
    end
  end
end
