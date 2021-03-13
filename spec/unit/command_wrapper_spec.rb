# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DotDiff::CommandWrapper do
  let(:base_img) { '/home/test/image 12343.png' }
  let(:new_img)  { '/home/test/img_1234 3.png' }
  let(:diff_img) { '/img/test 1.diff.png' }
  let(:escaped_cmd) do
    '/bin/compare -fuzz 5% /home/test/image\\ 12343.png /home/test/img_1234\\ 3.png /img/test\\ 1.diff.png 2>&1'
  end

  subject { DotDiff::CommandWrapper.new }

  before do
    DotDiff.image_magick_diff_bin = '/bin/compare'
    DotDiff.image_magick_options = '-fuzz 5%'
  end

  describe '#run' do
    it 'runs the command correctly escaped' do
      expect(subject.send(:command, base_img, new_img, diff_img)).to eq escaped_cmd
    end

    context 'when command output returns a number' do
      before do
        expect(subject).to receive(:run_command).and_return('97.0')
        subject.run('image_1', 'image_2', 'diff_image')
      end

      it 'sets failed to false' do
        expect(subject.failed?).to eq false
      end

      it 'sets pixels as parsed float' do
        expect(subject.pixels).to eq 97.0
      end

      it 'sets message with the output' do
        expect(subject.message).to eq '97.0'
      end
    end

    context "when it doesn't return a number" do
      let(:error) { 'compare: Image width/height do not match' }

      before do
        expect(subject).to receive(:run_command).and_return(error)
        subject.run('image_1', 'image_2', 'diff_image')
      end

      it 'sets failed to true' do
        expect(subject.failed?).to eq true
      end

      it 'sets message to the output' do
        expect(subject.message).to eq error
      end
    end

    context 'when the program doesnt exist' do
      let(:error) { Errno::ENOENT.new('No such file or directory - /bin/compare') }

      before do
        expect(subject).to receive(:run_command).and_raise(error)
      end

      it 'raises an exception' do
        expect { subject.run('image_1', 'image_2', 'diff_image') }.to raise_error(error)
      end
    end
  end
end
