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
      let(:comparer) { instance_double(DotDiff::Comparible::PageComparer)  }

      before do
        expect(element).to receive(:is_a?).with(Capybara::Session).and_return(true)
        expect(DotDiff::Comparible::PageComparer).to receive(:new)
          .with(snapshot, nil).and_return(comparer)
      end

      it 'calls page comparer' do
        expect(comparer).to receive(:run).and_return([true, ''])
        expect(subject.result).to eq([true, ''])
      end

      context 'when comparer result is false' do
        before do
          expect(comparer).to receive(:run).and_return([false, 'some failure'])

          allow(DotDiff).to receive(:failure_image_path).and_return('fake_path')
        end

        it 'resaves the new_image to .new' do
          expect(comparer).to receive(:new_image_path).and_return('fullscrn_path')
          expect(FileUtils).to receive(:mkdir_p).with('fake_path/images')
          expect(FileUtils).to receive(:mv).with('fullscrn_path', 'fake_path/images/test.new.png', force: true)

          expect(subject.result).to eq([false, 'some failure'])
        end

        context 'when no failure path set' do
          before do
            allow(DotDiff).to receive(:failure_image_path).and_return(nil)
          end

          it 'doesnt resave any file' do
            expect(FileUtils).not_to receive(:mkdir_p)
            expect(FileUtils).not_to receive(:mv)
            expect(subject.result).to eq([false, 'some failure'])
          end
        end
      end
    end

    context 'when element Capybara::Node::Base' do
      let(:comparer) { instance_double(DotDiff::Comparible::ElementComparer)  }
      let(:element_meta) { DotDiff::ElementMeta.new(page, element) }

      before do
        expect(element).to receive(:is_a?).with(Capybara::Session).and_return(false)
        expect(element).to receive(:is_a?).with(Capybara::Node::Base).and_return(true)

        expect(DotDiff::ElementMeta).to receive(:new).with(page, element).and_return(element_meta)
        expect(DotDiff::Comparible::ElementComparer).to receive(:new)
          .with(snapshot, element_meta).and_return(comparer)
      end

      it 'calls element comparer' do
        expect(comparer).to receive(:run).and_return([true, ''])
        expect(subject.result).to eq([true, ''])
      end

      context 'when comparer result is false' do
        before do
          expect(comparer).to receive(:run).and_return([false, 'some failure'])
          allow(DotDiff).to receive(:failure_image_path).and_return('fake_path')
        end

        it 'resaves the new_image to .new' do
          expect(comparer).to receive(:new_image_path).and_return('fullscrn_path')
          expect(FileUtils).to receive(:mkdir_p).with('fake_path/images')
          expect(FileUtils).to receive(:mv).with('fullscrn_path', 'fake_path/images/test.new.png', force: true)

          expect(subject.result).to eq([false, 'some failure'])
        end

        context 'when no failure path set' do
          before { allow(DotDiff).to receive(:failure_image_path).and_return(nil) }

          it 'doesnt resave any file' do
            expect(FileUtils).not_to receive(:mkdir_p)
            expect(FileUtils).not_to receive(:mv)
            expect(subject.result).to eq([false, 'some failure'])
          end
        end
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
