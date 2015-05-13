require 'test_helper'
require_relative '../lib/sandi_meter/cli'

describe SandiMeter::CLI do
  include FakeFS::SpecHelpers

  let(:cli) { SandiMeter::CLI }
  let(:gem_root) { File.expand_path('../', File.dirname(__FILE__)) }

  before do
    FakeFS.activate!

    FakeFS::FileSystem.clone(gem_root)
  end

  after do
    FakeFS.deactivate!
  end

  describe '#execute', silent_cli: true do
    before do
      @original_argv = ARGV
      ARGV.clear
    end

    after do
      ARGV.clear
      ARGV.concat(@original_argv)
    end

    context 'with the graph flag passed in' do
      before { ARGV.push('-g') }

      it 'opens the graph in a web browser' do
        expect(cli).to receive(:open_in_browser)
        expect { cli.execute }.to raise_error(SystemExit)
      end
    end

    context 'with the quiet flag passed in' do
      before do
        ARGV.push('-q')
        ARGV.push('-g')
      end

      it 'does not open the browser' do
        expect(cli).to_not receive(:open_in_browser)
        expect { cli.execute }.to raise_error(SystemExit)
      end
    end

    context 'output path passed in' do
      let(:test_path) { '/test_out_dir/test2' }
      before do
        ARGV.push('-q')
        ARGV.push('-g')
        ARGV.push('-o')
        ARGV.push(test_path)
      end

      it 'saves output files to specified output path' do
        expect { cli.execute }.to raise_error(SystemExit)
        expect(File.directory?(test_path)).to eq(true)
      end
    end

    context 'output path not specified' do
      before do
        ARGV.push('-q')
        ARGV.push('-g')
        ARGV.push('-p')
        ARGV.push('/')
      end

      it 'saves output files in sandi_meter folder relative to scanned path' do
        expect { cli.execute }.to raise_error(SystemExit)
        expect(File.directory?(File.expand_path('/sandi_meter'))).to eq(true)
      end
    end

    context 'makes account for rules thresholds' do
      context 'for low thresholds' do
        before do
          ARGV.push('-t')
          ARGV.push("1,1,1,1")
        end

        it 'terminates with 0 code' do
          expect { cli.execute }.to terminate.with_code(0)
        end
      end

      context 'for high thresholds' do
        before do
          ARGV.push('-t')
          ARGV.push("99,99,99,99")
        end

        it 'terminates with 1 code' do
          expect { cli.execute }.to terminate.with_code(1)
        end
      end
    end
  end
end
