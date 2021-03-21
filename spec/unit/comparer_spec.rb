# frozen_string_literal: true

require 'spec_helper'
require 'capybara/dsl'

RSpec.describe DotDiff::Comparer do
  let(:element) { MockElement.new }
  let(:page) { MockPage.new }
  let(:snapshot) { DotDiff::Snapshot.new(filename: 'test', subdir: 'images', page: page) }

  subject { DotDiff::Comparer.new(element, page, snapshot) }

  before { allow(DotDiff).to receive(:image_store_path).and_return('/home/se') }

  describe '#initialize' do
    it 'assigns options and element' do
      expect(subject.snapshot).to eq snapshot
      expect(subject.element).to eq element
      expect(subject.page).to eq page
    end
  end

  describe '#outcome' do
    context 'when element Capybara::Session' do
      it 'calls page comparer' do
        expect(element).to receive(:is_a?).with(Capybara::Session).and_return(true)
        expect(DotDiff::Comparible::PageComparer).to receive(:run).with(snapshot, nil).once

        subject.result
      end
    end

    context 'when element Capybara::Node::Base' do
      let(:element_meta) { DotDiff::ElementMeta.new(page, element) }

      it 'calls element comparer' do
        expect(element).to receive(:is_a?).with(Capybara::Session).and_return(false)
        expect(element).to receive(:is_a?).with(Capybara::Node::Base).and_return(true)

        expect(DotDiff::ElementMeta).to receive(:new).with(page, element).and_return(element_meta)
        expect(DotDiff::Comparible::ElementComparer).to receive(:run).with(snapshot, element_meta).once

        subject.result
      end
    end

    it 'raises an argument error when neither' do
      expect(element).to receive(:is_a?).with(Capybara::Session).and_return(false)
      expect(element).to receive(:is_a?).with(Capybara::Node::Base).and_return(false)

      expect { subject.result }.to raise_error(
        ArgumentError, 'Unknown element class received: MocksHelper::MockElement'
      )
    end
  end
end
