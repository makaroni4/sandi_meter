require 'fileutils'

module SandiMeter
  class Logger < Struct.new(:data)
    def log!(path)
      File.open(File.join(path, 'sandi_meter.log'), 'a') do |file|
        file.puts(log_line)
      end
    end

    private
    def log_line
      rules_log.join(';')
    end

    def log_rule(rule_key, proper_key, total_key)
      [
        data[rule_key][proper_key],
        data[rule_key][total_key] - data[rule_key][proper_key]
      ]
    end

    def rules_log
      log_line_data = [log_rule(:first_rule, :small_classes_amount, :total_classes_amount)]
      log_line_data += log_rule(:second_rule, :small_methods_amount, :total_methods_amount)
      log_line_data += log_rule(:third_rule, :proper_method_calls, :total_method_calls)
      log_line_data += log_rule(:fourth_rule, :proper_controllers_amount, :total_controllers_amount)
      log_line_data += [Time.now.to_i]
    end
  end
end

