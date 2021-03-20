# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DotDiff::ThresholdCalculator do
  describe '#under_threshold?' do
    context 'when existing pixel config' do
      it 'returns true' do
        expect(described_class.new(100, 1, 99).under_threshold?).to eq true
      end

      it 'returns false' do
        expect(described_class.new(100, 1, 101).under_threshold?).to eq false
      end
    end

    context 'when new pixel config' do
      it 'returns true' do
        expect(described_class.new({ type: 'pixel', value: 100 }, 1, 99).under_threshold?).to eq true
      end

      it 'returns false' do
        expect(described_class.new({ type: 'pixel', value: 100 }, 1, 101).under_threshold?).to eq false
      end
    end

    context 'when percent config' do
      it 'returns true' do
        expect(described_class.new({ type: 'percent', value: 0.333 }, 1000, 300).under_threshold?).to eq true
      end

      it 'returns false' do
        expect(described_class.new({ type: 'percent', value: 0.333 }, 1000, 334).under_threshold?).to eq false
      end
    end

    context 'when unknown config' do
      subject { described_class.new({ type: 'decimal', value: 100 }, 1, 1) }

      it 'raises an error' do
        expect { subject.under_threshold? }.to raise_error(DotDiff::UnknownTypeError)
      end
    end
  end

  describe '#message' do
    subject { described_class.new({ type: 'percent', value: 100 }, 999, 99) }

    before { subject.under_threshold? }

    it 'returns the calculated value and threshold type' do
      expect(subject.message).to eq "Outcome was '0.0990990990990991' difference for type 'percent'"
    end
  end
end
