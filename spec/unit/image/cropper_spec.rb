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

class MockChunkyPNG
  def crop!(x,y,w,h); end
  def save(file);  end
end

class MockElement
  def path; end
end

class MockPage
  def evaluate_script(cmd); end
end

RSpec.describe DotDiff::Image::Cropper do
  subject { Snappy.new }

  describe '#load_image' do
    it 'calls chunky_png image from file' do
      expect(ChunkyPNG::Image).to receive(:from_file).with('/home/se/full.png').once
      subject.send(:load_image, '/home/se/full.png')
    end
  end

  describe '#crop_and_resave' do
    let(:element) { DotDiff::ElementMeta.new(MockPage.new, MockElement.new) }
    let(:rectangle) { DotDiff::ElementMeta::Rectangle.new(MockPage.new, MockElement.new) }
    let(:mock_png) { MockChunkyPNG.new }

    before do
      allow(element).to receive(:rectangle).and_return(rectangle)
      allow(rectangle).to receive(:rect).and_return(
        {'top' => 2, 'left' => 1, 'height' => 4, 'width' => 3}
      )
    end

    it 'calls load_image crop and save' do
      expect(subject).to receive(:load_image).with('/home/se/full.png').and_return(mock_png).once
      expect(mock_png).to receive(:crop!).with(1,2,3,4).once
      expect(mock_png).to receive(:save).with('/tmp/T/cropped.png').once

      subject.crop_and_resave(element)
    end
  end
end

