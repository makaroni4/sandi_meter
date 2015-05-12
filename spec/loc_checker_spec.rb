require 'test_helper'
require_relative '../lib/sandi_meter/loc_checker'

describe SandiMeter::LOCChecker do
  let(:checker) { SandiMeter::LOCChecker.new([]) }

  describe '#check' do
    context 'for short code' do
      before do
        stub_const('SandiMeter::LOCChecker::MAX_LOC', { 'blah' => 10 })
        allow(checker).to receive(:locs_size).and_return(rand(0..10))
      end

      # REFACTOR
      # avoid passing dumb arguments to tested methods
      it 'passes the check' do
        expect(checker.check([1,2,3], 'blah')).to eq true
      end
    end

    context 'for large code' do
      before do
        stub_const('SandiMeter::LOCChecker::MAX_LOC', { 'blah' => 10 })
        allow(checker).to receive(:locs_size).and_return(rand(11..100))
      end

      it 'does not pass the check' do
        expect(checker.check([1,2,3], 'blah')).to eq false
      end
    end
  end
end
