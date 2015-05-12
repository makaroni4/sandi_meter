require 'test_helper'
require_relative '../lib/sandi_meter/method_arguments_counter'

describe SandiMeter::MethodArgumentsCounter do
  let(:test_loader) { SandiMeter::ArgsLoader.new }
  let(:analyzer) { SandiMeter::MethodArgumentsCounter.new }

  context 'when variable/method arguments' do
    let(:args_add_block_1) { load_args_block('blah arg1, arg2')}
    let(:args_add_block_2) { load_args_block('blah(arg1, arg2)')}

    it 'counts arguments' do
      expect(analyzer.count(args_add_block_1)).to eq([2, 1])
      expect(analyzer.count(args_add_block_2)).to eq([2, 1])
    end
  end

  context 'when hash arguments' do
    let(:args_add_block_1) { load_args_block('blah k: :v') }
    let(:args_add_block_2) { load_args_block('blah(k: :v)') }

    let(:args_add_block_3) { load_args_block('blah k1: :v1, k2: :v2') }
    let(:args_add_block_4) { load_args_block('blah(k1: :v1, k2: :v2)') }

    it 'counts arguments' do
      expect(analyzer.count(args_add_block_1)).to eq([1, 1])
      expect(analyzer.count(args_add_block_2)).to eq([1, 1])
      expect(analyzer.count(args_add_block_3)).to eq([2, 1])
      expect(analyzer.count(args_add_block_4)).to eq([2, 1])
    end
  end

  context 'when variable/method with hash' do
    let(:code_1) { load_args_block('blah arg_1, arg_2, k: :v') }
    let(:code_2) { load_args_block('blah(arg_1, arg_2, k: :v)') }
    let(:code_3) { load_args_block('blah arg_1, arg_2, k1: :v1, k2: :v2') }
    let(:code_4) { load_args_block('blah(arg_1, arg_2, k1: :v1, k2: :v2)') }

    it 'counts arguments' do
      expect(analyzer.count(code_1)).to eq([3, 1])
      expect(analyzer.count(code_2)).to eq([3, 1])
    end

    it 'counts hash keys as argumets' do
      expect(analyzer.count(code_3)).to eq([4, 1])
      expect(analyzer.count(code_4)).to eq([4, 1])
    end
  end

  context 'when argument with default value' do
    let(:code_1) { load_args_block('blah arg_1 = "blah"') }
    let(:code_2) { load_args_block('blah(arg_1 = "blah")') }

    it 'counts arguments' do
      expect(analyzer.count(code_1)).to eq([1, 1])
      expect(analyzer.count(code_2)).to eq([1, 1])
    end
  end
end
