require 'test_helper'
require_relative '../lib/loc_checker'

describe LOCChecker do
  let(:checker) { LOCChecker.new([]) }

  describe '#check' do
    context 'for short code' do
      before do
        stub_const('LOCChecker::MAX_LOC', { 'blah' => 10 })
        checker.stub(:locs_size).and_return(rand(0..10))
      end

      # REFACTOR
      # avoid passing dumb arguments to tested methods
      it 'passes the check' do
        checker.check([1,2,3], 'blah').should be_true
      end
    end

    context 'for large code' do
      before do
        stub_const('LOCChecker::MAX_LOC', { 'blah' => 10 })
        checker.stub(:locs_size).and_return(rand(11..100))
      end

      it 'does not pass the check' do
        checker.check([1,2,3], 'blah').should be_false
      end
    end
  end
end
