require 'fileutils'
require 'json'

module SandiMeter
  class HtmlGenerator
    def copy_assets!(path)
      asset_dir_path = File.join(path, 'assets')
      FileUtils.mkdir(asset_dir_path) unless Dir.exists?(asset_dir_path)
      html_dir = File.expand_path('../../html', File.dirname(__FILE__))

      Dir[File.join(html_dir, "*.{js,css,png}")].each do |file|
        FileUtils.cp file, File.join(asset_dir_path, File.basename(file))
      end

      FileUtils.cp File.join(html_dir, 'index.html'), File.join(path, 'index.html')
    end

    def generate_data!(path)
      raw_data = File.read(File.join(path, 'sandi_meter.log')).split("\n")
      raw_data.map! { |row| row.split(';').map(&:to_i) }

      data = []
      raw_data.each do |row|
        hash = {}
        row.first(8).each_slice(2).each_with_index do |el, i|
          hash["r#{i + 1}0"] = el.first
          hash["r#{i + 1}1"] = el.last
        end

        hash['timestamp'] = row.last * 1000
        data << hash
      end

      index_file = File.join(path, 'index.html')
      index = File.read(index_file)
      index.gsub!('<% plot_data %>', data.to_json)

      File.open(index_file, 'w') do |file|
        file.write(index)
      end
    end

    def generate_details!(path, data)
      details = ""

      if data[:first_rule][:log][:classes].any?
        data[:first_rule][:log][:misindented_classes] ||= []
        data[:first_rule][:log][:misindented_classes].each do |class_params|
          class_params.insert(1, nil)
        end

        details << string_to_h2("Classes with 100+ lines")
        details << generate_details_block(
          ["Class name", "Size", "Path"],
          proper_data: data[:first_rule][:log][:classes],
          warning_data: data[:first_rule][:log][:misindented_classes],
          hint: "NOTE: Red classes are misindented. Start improving your project by fixing them.",
          warning_message: 'Misindented classes'
        )
      end

      if data[:second_rule][:log][:methods].any?
        data[:second_rule][:log][:misindented_methods] ||= []
        data[:second_rule][:log][:misindented_methods].each do |method_params|
          method_params.insert(2, nil)
        end

        details << string_to_h2("Methods with 5+ lines")
        details << generate_details_block(
          ["Class name", "Method name", "Size", "Path"],
          proper_data: data[:second_rule][:log][:methods].sort_by { |a| -a[2].to_i },
          warning_data: data[:second_rule][:log][:misindented_methods].sort_by { |a| -a[1].to_i },
          hint: "NOTE: Red methods are misindented. Continue your way to perfect code by fixing them.",
          warning_message: 'Misindented methods'
        )
      end

      if data[:third_rule][:log][:method_calls].any?
        details << string_to_h2("Method calls with 4+ arguments")
        details << generate_details_block(
          ["# of arguments", "Path"],
          proper_data: data[:third_rule][:log][:method_calls]
        )
      end

      if data[:fourth_rule][:log][:controllers].any?
        details << string_to_h2("Controllers with 1+ instance variables")
        details << generate_details_block(
          ["Controller name", "Action name", "Instance variables"],
          proper_data: data[:fourth_rule][:log][:controllers]
        )
      end

      index_file = File.join(path, 'index.html')
      index = File.read(index_file)
      index.gsub!('<% details %>', details)

      File.open(index_file, 'w') do |file|
        file.write(index)
      end
    end

    private
    def generate_details_block(head_row, data)
      block_partial = File.read File.join(File.dirname(__FILE__), "../../html", "_detail_block.html")
      block_partial.gsub!('<% head %>', array_to_tr(head_row, cell: "th"))

      table_rows = data[:proper_data].map { |row| array_to_tr(row) }.join('')

      if data[:warning_data]
        table_rows << data[:warning_data].map { |row| array_to_tr(row, css_class: 'warning', tip: data[:warning_message]) }.join('')
      end

      block_partial.gsub!('<% rows %>', table_rows)
      block_partial << hint(data[:hint]) if data[:hint]
      block_partial
    end

    def hint(string)
      %(<div class="hint">#{string}</div>)
    end

    def string_to_h2(string)
      "<h2>#{string}</h2>\n"
    end

    def cell_to_s(element)
      element.kind_of?(Array) ? element.join(', ') : element.to_s
    end

    def array_to_tr(array, params = {})
      cell = params[:cell] || "td"
      array.map { |element| "<#{cell} class=\"#{params[:css_class]}\" title=\"#{params[:tip]}\">#{cell_to_s(element)}</#{cell}>\n" }.join('').prepend("<tr>\n").concat("</tr>\n")
    end
  end
end
