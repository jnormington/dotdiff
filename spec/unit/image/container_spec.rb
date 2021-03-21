# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DotDiff::Image::Container do
  let(:baseimg_file) { 'baseimg_file.png' }
  let(:newimg_file) { 'newimg_file.png' }

  subject { described_class.new(baseimg_file, newimg_file) }

  describe '#both_image_same_dimensions' do
    before do
      expect(Magick::Image).to receive(:read).with(baseimg_file).and_return([base_img])
      expect(Magick::Image).to receive(:read).with(newimg_file).and_return([new_img])
    end

    context 'when both rows and columns match' do
      let(:base_img) { instance_double(Magick::Image, rows: 100, columns: 120) }
      let(:new_img) { instance_double(Magick::Image, rows: 100, columns: 120) }

      it 'returns true' do
        expect(subject.both_images_same_dimensions?).to eq true
      end
    end

    context 'when the rows are mismatch' do
      let(:base_img) { instance_double(Magick::Image, rows: 101, columns: 120) }
      let(:new_img) { instance_double(Magick::Image, rows: 100, columns: 120) }

      it 'returns false' do
        expect(subject.both_images_same_dimensions?).to eq false
      end
    end

    context 'when the rows are mismatch' do
      let(:base_img) { instance_double(Magick::Image, rows: 100, columns: 120) }
      let(:new_img) { instance_double(Magick::Image, rows: 100, columns: 121) }

      it 'returns false' do
        expect(subject.both_images_same_dimensions?).to eq false
      end
    end
  end

  describe '#total_pixels' do
    let(:base_img) { instance_double(Magick::Image, rows: 1280, columns: 764) }

    before do
      expect(Magick::Image).to receive(:read).with(baseimg_file).and_return([base_img])
    end

    it 'returns the total pixels' do
      expect(subject.total_pixels).to eq 977_920
    end
  end

  describe '#dimensions_mismatch_msg' do
    let(:base_img) { instance_double(Magick::Image, rows: 100, columns: 120) }
    let(:new_img) { instance_double(Magick::Image, rows: 100, columns: 121) }

    before do
      expect(Magick::Image).to receive(:read).with(baseimg_file).and_return([base_img])
      expect(Magick::Image).to receive(:read).with(newimg_file).and_return([new_img])
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
