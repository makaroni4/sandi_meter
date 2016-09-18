require 'test_helper'
require_relative '../lib/sandi_meter/last_line'

describe SandiMeter::LastLine do
  describe '.find' do
    shared_examples_for 'finding last line number' do
      let(:file_lines) { ["#{token} A; end",
                          "#{token} B",
                          '  if test_true?',
                          '    puts "Hi Mom"',
                          '  end',
                          'end',
                          "#{token} C",
                          '  unless test_false?',
                          '    puts "Hey Dad"',
                          '  end',
                          '  end'] }
      context 'when one liner' do

        let(:start_line) { 1 }
        it 'returns nil' do
          expect(described_class.find(start_line, token, file_lines)).to be_nil
        end
      end

      context 'when multiline' do
        context 'when end found with same indentation' do
          let(:start_line) { 2 }
          it 'returns line number of last line' do
            expect(described_class.find(start_line, token, file_lines)).to eq(6)
          end
        end

        context 'when no end found with same indentation' do
          let(:start_line) { 7 }
          it 'returns nil' do
            expect(described_class.find(start_line, token, file_lines)).to be_nil
          end
        end
      end
    end

    context 'when class token' do
      let(:token) { 'class' }
      it_should_behave_like 'finding last line number'
    end

    context 'when module token' do
      let(:token) { 'module' }
      it_should_behave_like 'finding last line number'
    end

    context 'when def token (method)' do
      let(:token) { 'def' }
      it_should_behave_like 'finding last line number'
    end
  end
end
