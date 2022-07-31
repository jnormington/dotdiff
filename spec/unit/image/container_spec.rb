# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DotDiff::Image::Container do
  let(:baseimg_file) { 'baseimg_file.png' }
  let(:newimg_file) { 'newimg_file.png' }

  subject { described_class.new(baseimg_file, newimg_file) }

  describe '#both_image_same_dimensions' do
    before do
      expect(MiniMagick::Image).to receive(:open).with(baseimg_file).and_return(base_img)
      expect(MiniMagick::Image).to receive(:open).with(newimg_file).and_return(new_img)
    end

    context 'when both width and height match' do
      let(:base_img) { instance_double(MiniMagick::Image, width: 120, height: 100) }
      let(:new_img) { instance_double(MiniMagick::Image, width: 120, height: 100) }

      it 'returns true' do
        expect(subject.both_images_same_dimensions?).to eq true
      end
    end

    context 'when the height are mismatch' do
      let(:base_img) { instance_double(MiniMagick::Image, width: 120, height: 101) }
      let(:new_img) { instance_double(MiniMagick::Image, width: 120, height: 100) }

      it 'returns false' do
        expect(subject.both_images_same_dimensions?).to eq false
      end
    end

    context 'when the height are mismatch' do
      let(:base_img) { instance_double(MiniMagick::Image, width: 120, height: 100) }
      let(:new_img) { instance_double(MiniMagick::Image, width: 121, height: 100) }

      it 'returns false' do
        expect(subject.both_images_same_dimensions?).to eq false
      end
    end
  end

  describe '#total_pixels' do
    let(:base_img) { instance_double(MiniMagick::Image, width: 764, height: 1280) }

    before do
      expect(MiniMagick::Image).to receive(:open).with(baseimg_file).and_return(base_img)
    end

    it 'returns the total pixels' do
      expect(subject.total_pixels).to eq 977_920
    end
  end

  describe '#dimensions_mismatch_msg' do
    let(:base_img) { instance_double(MiniMagick::Image, width: 120, height: 100) }
    let(:new_img) { instance_double(MiniMagick::Image, width: 121, height: 100) }

    before do
      expect(MiniMagick::Image).to receive(:open).with(baseimg_file).and_return(base_img)
      expect(MiniMagick::Image).to receive(:open).with(newimg_file).and_return(new_img)
    end

    it 'returns a message with the dimensions' do
      expect(subject.dimensions_mismatch_msg).to eq(
        <<~MSG
          Images are not the same dimensions to be compared
          Base file: 120x100
          New file:  121x100
        MSG
      )
    end
  end
end
