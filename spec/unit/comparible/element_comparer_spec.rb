# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DotDiff::Comparible::ElementComparer do
  let(:element_meta) { instance_double(DotDiff::ElementMeta) }
  let(:snapshot) do
    instance_double(
      DotDiff::Snapshot, basefile: 'test', fullscreen_file: 'fullscrn_file',
                         capture_from_browser: true, diff_file: 'diff_file',
                         cropped_file: 'crped_file', resave_fullscreen_file: true
    )
  end

  before do
    expect(snapshot).to receive(:crop_and_resave).with(element_meta)
    expect(DotDiff).to receive(:hide_elements_on_non_full_screen_screenshot).and_return(true)
  end

  describe '#run' do
    it 'captures a screenshot from the browser' do
      allow(snapshot).to receive(:resave_cropped_file)
      expect(snapshot).to receive(:capture_from_browser).with(true).once
      described_class.run(snapshot, element_meta)
    end

    it 'checks if the basefile exists' do
      allow(snapshot).to receive(:resave_cropped_file)
      expect(File).to receive(:exist?).with(snapshot.basefile).and_return(false)
      described_class.run(snapshot, element_meta)
    end

    context 'when the basefile doesnt exist' do
      subject { described_class.run(snapshot, element_meta) }

      before do
        expect(File).to receive(:exist?).with(snapshot.basefile).and_return(false)
      end

      it 'calls resave_cropped_file and returns true' do
        expect(snapshot).to receive(:resave_cropped_file)
        expect(subject).to eq [true, snapshot.basefile]
      end
    end

    context 'when the basefile exists' do
      subject { described_class.run(snapshot, element_meta) }

      before do
        expect(DotDiff::CommandWrapper).to receive(:new).and_return(command_wrapper)
        expect(command_wrapper).to receive(:run).with('test', 'crped_file', 'diff_file').and_return(nil)
        expect(File).to receive(:exist?).with(snapshot.basefile).and_return(true)
      end

      context 'and the command fails to return pixels' do
        let(:command_wrapper) do
          instance_double(DotDiff::CommandWrapper, passed?: false, failed?: true, message: 'Some failure')
        end

        it 'returns false and the error message' do
          expect(subject).to eq [false, 'Some failure']
        end
      end

      context 'and the command succeeds' do
        let(:command_wrapper) do
          instance_double(DotDiff::CommandWrapper,
                          pixels: 3210.0, passed?: true, failed?: false, message: '3210')
        end

        let(:rmagick_image) { instance_double(Magick::Image, rows: 1920, columns: 1080) }
        let(:calc) { instance_double(DotDiff::ThresholdCalculator) }

        before do
          expect(Magick::Image).to receive(:read).with('test').and_return([rmagick_image])
          expect(DotDiff).to receive(:pixel_threshold).and_return(100)
          expect(DotDiff::ThresholdCalculator).to receive(:new).with(100, 2_073_600, 3210.0).and_return(calc)
        end

        context 'when calc under threshold' do
          let(:calc) do
            instance_double(DotDiff::ThresholdCalculator, value: 0.154, message: 'Some msg', under_threshold?: true)
          end

          it 'returns true' do
            expect(subject).to eq [true, 'Some msg']
          end
        end

        context 'when calc over threshold' do
          let(:calc) do
            instance_double(DotDiff::ThresholdCalculator, value: 0.154, message: 'Some msg', under_threshold?: false)
          end

          it 'returns true' do
            expect(subject).to eq [false, 'Some msg']
          end
        end
      end
    end
  end
end
