# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DotDiff::CommandWrapper do
  subject { DotDiff::CommandWrapper.new }

  before do
    DotDiff.image_magick_diff_bin = '/bin/compare'
    DotDiff.image_magick_options = '-fuzz 5%'
  end

  describe '#command' do
    let(:base_img) { '/home/test/image 12343.png' }
    let(:new_img)  { '/home/test/img_1234 3.png' }
    let(:diff_img) { '/img/test 1.diff.png' }
    let(:escaped_cmd) do
      '/bin/compare -fuzz 5% /home/test/image\\ 12343.png /home/test/img_1234\\ 3.png /img/test\\ 1.diff.png 2>&1'
    end

    it 'escapes both base and new file names and contains the additional options' do
      expect(subject.send(:command, base_img, new_img, diff_img)).to eq escaped_cmd
    end
  end

  describe '#run' do
    before { DotDiff.pixel_threshold = 98.23 }

    context 'when it returns a number' do
      it 'returns failed as false when it is under the threshold' do
        allow(subject).to receive(:run_command).and_return('97.0')

        subject.run('image_1', 'image_2', 'diff_image')
        expect(subject.failed?).to be_falsey
        expect(subject.message).to be_nil
      end

      it 'returns failed as false when it is equal to the threshold' do
        allow(subject).to receive(:run_command).and_return('98.23')

        subject.run('image_1', 'image_2', 'diff_image')
        expect(subject.failed?).to be_falsey
        expect(subject.message).to be_nil
      end

      it 'returns failed as true with pixel diff message' do
        allow(subject).to receive(:run_command).and_return('98.43')
        subject.run('image_1', 'image_2', 'diff_image')

        expect(subject.failed?).to be_truthy
        expect(subject.message).to eq 'Images are 98.43 pixels different'
      end
    end

    context "when it doesn't return a number" do
      let(:error) { 'compare: Image width/height do not match' }

      before do
        allow(subject).to receive(:run_command).and_return(error)
        subject.run('image_1', 'image_2', 'diff_image')
      end

      it 'assigns true to failed when return stdout is not a float' do
        expect(subject.failed?).to be_truthy
        expect(subject.message).to eq error
      end
    end

    context 'when the program doesnt exist' do
      let(:error) { 'No such file or directory - /bin/compare' }

      it 'raises an exception when program not found' do
        allow(subject).to receive(:run_command).and_return(error)
        subject.run('image_1', 'image_2', 'diff_image')

        expect(subject.failed?).to be_truthy
        expect(subject.message).to eq error
      end
    end
  end
end
