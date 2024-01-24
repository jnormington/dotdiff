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

      expect(mock_png).to receive(:write).with('/tmp/T/cropped.png').once
    end

    it 'calls load_image crop and save' do
      allow(rectangle).to receive(:rect).and_return(
        { 'top' => 2, 'left' => 1, 'height' => 4, 'width' => 3 }
      )

      expect(mock_png).to receive(:crop).with("3x4+1+2").once

      subject.crop_and_resave(element)
    end

    it 'correctly crops when the browser returns floating point numbers' do
      allow(rectangle).to receive(:rect).and_return(
        { 'top' => 2.3, 'left' => 1.3, 'height' => 4.2, 'width' => 3.2 }
      )

      expect(mock_png).to receive(:crop).with("4x5+1+2").once

      subject.crop_and_resave(element)
    end

    it 'correctly shifts the cropped position when rounding leads to a bigger image' do
      allow(rectangle).to receive(:rect).and_return(
        { 'top' => 2.9, 'left' => 1.2, 'height' => 3.6, 'width' => 2.9 }
      )

      expect(mock_png).to receive(:crop).with("3x4+2+3").once

      subject.crop_and_resave(element)
    end
  end
end
