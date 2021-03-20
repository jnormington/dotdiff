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
      expect(subject.pixel_threshold).to eq 100
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
end
