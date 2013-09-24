require 'fileutils'
require 'json'

module SandiMeter
  class HtmlGenerator
    def copy_assets!(path)
      asset_dir_path = File.join(path, 'sandi_meter/assets')
      FileUtils.mkdir(asset_dir_path) unless Dir.exists?(asset_dir_path)


      Dir[File.join(File.dirname(__FILE__), "../../html/*.{js,css}")].each do |file|
        FileUtils.cp file, File.join(asset_dir_path, File.basename(file))
      end

      FileUtils.cp File.join(File.dirname(__FILE__), "../../html", "index.html"), File.join(path, 'sandi_meter', 'index.html')
    end

    def generate_data!(path)
      raw_data = File.read(File.join(path, 'sandi_meter', 'sandi_meter.log')).split("\n")
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

      index_file = File.join(path, 'sandi_meter', 'index.html')
      index = File.read(index_file)
      index.gsub!('<% plot_data %>', data.to_json)

      File.open(index_file, 'w') do |file|
        file.write(index)
      end
    end
  end
end
