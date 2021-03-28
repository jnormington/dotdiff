# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DotDiff::Comparible::PageComparer do
  let(:snapshot) do
    instance_double(
      DotDiff::Snapshot, basefile: 'test', fullscreen_file: 'fullscrn_file',
                         capture_from_browser: true, diff_file: 'diff_file',
                         resave_fullscreen_file: true
    )
  end

  describe '#run' do
    it 'captures a screenshot from the browser' do
      expect(snapshot).to receive(:capture_from_browser).with(true).once
      described_class.run(snapshot, nil)
    end

    it 'checks if the basefile exists' do
      expect(File).to receive(:exist?).with(snapshot.basefile).and_return(false)
      described_class.run(snapshot, nil)
    end

    context 'when the basefile doesnt exist' do
      subject { described_class.run(snapshot, nil) }

      it 'returns true' do
        expect(File).to receive(:exist?).with(snapshot.basefile).and_return(false)
        expect(subject).to eq [true, snapshot.basefile]
      end
    end

    context 'when the new and base image size are different' do
      let(:container) do
        instance_double(DotDiff::Image::Container,
                        total_pixels: 2_073_600,
                        both_images_same_dimensions?: false,
                        dimensions_mismatch_msg: 'Some dimensions mismatch')
      end

      before do
        expect(File).to receive(:exist?).with(snapshot.basefile).and_return(true)
        expect(DotDiff::Image::Container).to receive(:new)
          .with(snapshot.basefile, 'fullscrn_file').and_return(container)
      end

      it 'returns false with a message' do
        expect(described_class.run(snapshot, nil)).to eq [false, 'Some dimensions mismatch']
      end
    end

    context 'when the basefile exists' do
      let(:container) do
        instance_double(DotDiff::Image::Container,
                        total_pixels: 2_073_600,
                        both_images_same_dimensions?: true)
      end

      subject { described_class.run(snapshot, nil) }

      before do
        expect(DotDiff::CommandWrapper).to receive(:new).and_return(command_wrapper)
        expect(command_wrapper).to receive(:run).with('test', 'fullscrn_file', 'diff_file').and_return(nil)
        expect(File).to receive(:exist?).with(snapshot.basefile).and_return(true)
        expect(DotDiff::Image::Container).to receive(:new)
          .with(snapshot.basefile, 'fullscrn_file').and_return(container)
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
          instance_double(DotDiff::CommandWrapper, pixels: 321.0, passed?: true, failed?: false, message: '321')
        end

        context 'when pixels under threshold' do
          let(:calc) do
            instance_double(DotDiff::ThresholdCalculator, message: 'Some msg', under_threshold?: true)
          end

          before do
            expect(DotDiff).to receive(:pixel_threshold).and_return(322)
            expect(DotDiff::ThresholdCalculator).to receive(:new).with(322, 2_073_600, 321.0).and_return(calc)
          end

          it 'returns true' do
            expect(subject).to eq [true, 'Some msg']
          end
        end

        context 'when pixels over threshold' do
          let(:calc) do
            instance_double(DotDiff::ThresholdCalculator, message: 'Some msg', under_threshold?: false)
          end

          before do
            expect(DotDiff).to receive(:pixel_threshold).and_return(320)
            expect(DotDiff::ThresholdCalculator).to receive(:new).with(320, 2_073_600, 321.0).and_return(calc)
          end

          it 'returns false' do
            expect(subject).to eq [false, 'Some msg']
          end
        end
      end
    end
  end

  describe '#new_image_path' do
    subject { described_class.new(snapshot, nil) }

    it 'returns cropped file path' do
      expect(subject.new_image_path).to eq 'fullscrn_file'
    end
  end
end
