# frozen_string_literal: true

require 'spec_helper'

class Snappy
  include DotDiff::Image::Cropper

  def fullscreen_file
    '/home/se/full.png'
  end

  def cropped_file
    '/tmp/T/cropped.png'
  end
end

class MockMiniMagick
  def crop(format); end

  def write(file); end

  def width; end

  def height; end
end

RSpec.describe DotDiff::Image::Cropper do
  subject { Snappy.new }

  let(:element) { DotDiff::ElementMeta.new(MockPage.new, MockElement.new) }
  let(:mock_png) { MockMiniMagick.new }

  describe '#load_image' do
    it 'calls minimagick image open' do
      expect(MiniMagick::Image).to receive(:open).with('/home/se/full.png').once.and_return(nil)
      subject.send(:load_image, '/home/se/full.png')
    end
  end

  describe '#crop_and_resave' do
    let(:rectangle) { DotDiff::ElementMeta::Rectangle.new(MockPage.new, element) }

    before do
      allow(element).to receive(:rectangle).and_return(rectangle)

      expect(subject).to receive(:load_image).with('/home/se/full.png').and_return(mock_png).once
      expect(subject).to receive(:width).with(element, mock_png).and_return(13).once
      expect(subject).to receive(:height).with(element, mock_png).and_return(14).once

      expect(mock_png).to receive(:crop).with("13x14+1+2").once
      expect(mock_png).to receive(:write).with('/tmp/T/cropped.png').once
    end

    it 'calls load_image crop and save' do
      allow(rectangle).to receive(:rect).and_return(
        { 'top' => 2, 'left' => 1, 'height' => 4, 'width' => 3 }
      )

      subject.crop_and_resave(element)
    end

    it 'rounds down the x and y values received from the browser' do
      allow(rectangle).to receive(:rect).and_return(
        { 'top' => 2.3, 'left' => 1.7, 'height' => 4.5, 'width' => 3.6 }
      )

      subject.crop_and_resave(element)
    end
  end

  describe '#height' do
    before { allow(element.rectangle).to receive(:rect).and_return(rect) }

    context 'when element height is larger than the image height' do
      let(:rect) { { 'top' => -180, 'left' => 0, 'width' => 800, 'height' => 1400 } }

      it 'returns the image height minus the top point' do
        allow(mock_png).to receive(:height).and_return(1200)
        expect(subject.height(element, mock_png)).to eq 1380
      end
    end

    context 'when element height is smaller than the image height' do
      let(:rect) { { 'top' => -180, 'left' => 0, 'width' => 500, 'height' => 800 } }

      it 'returns the element height' do
        allow(mock_png).to receive(:height).and_return(1200)
        expect(subject.height(element, mock_png)).to eq 800
      end
    end
  end

  describe '#width' do
    before { allow(element.rectangle).to receive(:rect).and_return(rect) }

    context 'when element width is larger than the image width' do
      let(:rect) { { 'top' => -180, 'left' => -30, 'width' => 731, 'height' => 1200 } }

      it 'returns the image width minus the left point' do
        allow(mock_png).to receive(:width).and_return(700)
        expect(subject.width(element, mock_png)).to eq 730
      end
    end

    context 'when element width is smaller than the image width' do
      let(:rect) { { 'top' => -180, 'left' => -20, 'width' => 800, 'height' => 800 } }

      it 'returns the element width' do
        allow(mock_png).to receive(:width).and_return(850)
        expect(subject.width(element, mock_png)).to eq 800
      end
    end
  end
end
