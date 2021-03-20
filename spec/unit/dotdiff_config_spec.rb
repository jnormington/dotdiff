# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Dotdiff configuration' do
  subject { DotDiff }
  let(:user_methods) do
    (DotDiff.public_methods - Object.public_methods).reject do |mth|
      mth.to_s.include?('=') || mth == :configure
    end
  end

  before(:each) do
    user_methods.each { |mth| DotDiff.instance_variable_set("@#{mth}", nil) }
  end

  describe '#resave_base_image' do
    it 'returns false when not set' do
      expect(subject.resave_base_image).to eq false
    end

    it 'returns user defined value' do
      subject.resave_base_image = true
      expect(subject.resave_base_image).to be_truthy
    end
  end

  describe '#image_magick_diff_bin' do
    it 'trims any newlines' do
      DotDiff.image_magick_diff_bin = "/usr/bin/compare\n"
      expect(DotDiff.image_magick_diff_bin).to eq '/usr/bin/compare'
    end
  end

  describe '#image_magick_options' do
    let(:opts) { '-fuzz 10% -metric phash' }

    after { DotDiff.image_magick_options = nil }

    it 'returns the default options' do
      expect(subject.image_magick_options).to eq '-fuzz 5% -metric AE'
    end

    it 'returns the user set options' do
      DotDiff.image_magick_options = opts
      expect(subject.image_magick_options).to eq opts
    end
  end

  describe 'pixel_threshold' do
    after { DotDiff.pixel_threshold = nil }

    it 'returns the default 100 pixels' do
      expect(subject.pixel_threshold).to eq({ type: 'pixel', value: 100 })
    end

    it 'returns the user defined value' do
      DotDiff.pixel_threshold = 120
      expect(subject.pixel_threshold).to eq 120
    end
  end

  describe '#image_store_path' do
    let(:path) { '/tmp/image_store_path' }

    after { DotDiff.image_store_path = nil }

    it 'returns the user set value' do
      DotDiff.image_store_path = path
      expect(subject.image_store_path).to eq path
    end
  end

  describe '#failure_image_path' do
    let(:path) { '/tmp/failed_image_store' }

    after { DotDiff.failure_image_path = nil }

    it 'returns the user set value' do
      DotDiff.failure_image_path = path
      expect(subject.failure_image_path).to eq path
    end
  end

  describe '#xpath_elements_to_hide' do
    let(:elems) { ["document.findElementByid('f')", ''] }
    it 'defaults to an empty array' do
      expect(subject.xpath_elements_to_hide).to eq []
    end

    it 'returns the user elements' do
      DotDiff.xpath_elements_to_hide = elems
      expect(subject.xpath_elements_to_hide).to eq elems
    end
  end

  describe '#pixel_threshold' do
    after { DotDiff.pixel_threshold = nil }

    context 'when value not a hash' do
      it 'raises a deprecation warning' do
        expect(Kernel).to receive(:warn).with(
          '[Dotdiff deprecation] Pass a hash options instead of integer to support pixel/percentage threshold'
        ).twice

        DotDiff.pixel_threshold = 120
      end

      it 'sets the value' do
        DotDiff.pixel_threshold = 120
        expect(DotDiff.pixel_threshold).to eq 120
      end
    end

    context 'when type is pixel' do
      let(:config) { DotDiff.pixel_threshold = { type: 'pixel', value: 120 } }

      it 'sets the config value' do
        DotDiff.pixel_threshold = config
        expect(DotDiff.pixel_threshold).to eq config
      end
    end

    context 'when type is percent' do
      let(:config) { DotDiff.pixel_threshold = { type: 'percent', value: 0.9999 } }

      it 'sets the config value' do
        DotDiff.pixel_threshold = config
        expect(DotDiff.pixel_threshold).to eq config
      end
    end

    context 'when type is percent' do
      let(:config) { DotDiff.pixel_threshold = { type: 'percent', value: 1 } }

      it 'sets the config value' do
        DotDiff.pixel_threshold = config
        expect(DotDiff.pixel_threshold).to eq config
      end
    end

    context 'when type is percent and value over 1' do
      let(:config) { DotDiff.pixel_threshold = { type: 'percent', value: 1.01 } }

      it 'raises an error' do
        expect do
          DotDiff.pixel_threshold = config
        end.to raise_error DotDiff::InvalidValueError, 'Percent value should be a float between 0 and 1'
      end
    end

    context 'when value not an invalid option' do
      it 'raises an exception' do
        expect do
          DotDiff.pixel_threshold = { type: 'decimal', value: 120 }
        end.to raise_error(DotDiff::UnknownTypeError)
      end
    end
  end
end
