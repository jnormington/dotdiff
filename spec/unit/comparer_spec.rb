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
      it 'calls compare_page' do
        expect(element).to receive(:is_a?).with(Capybara::Session).and_return(true)
        expect(subject).to receive(:compare_page).once

        subject.result
      end
    end

    context 'when element Capybara::Node::Base' do
      it 'calls compare_element' do
        expect(element).to receive(:is_a?).with(Capybara::Session).and_return(false)
        expect(element).to receive(:is_a?).with(Capybara::Node::Base).and_return(true)
        expect(subject).to receive(:compare_element).once

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

  describe '#compare_element' do
    let(:element_meta) { DotDiff::ElementMeta.new(page, element) }

    context 'file exists' do
      it 'calls compare with cropped file location' do
        expect(DotDiff).to receive(:hide_elements_on_non_full_screen_screenshot).and_return(true)

        expect(snapshot).to receive(:capture_from_browser).with(true).once
        expect(snapshot).to receive(:crop_and_resave).with(element_meta).once
        expect(File).to receive(:exist?).with(snapshot.basefile).and_return(true)
        expect(subject).to receive(:compare).with(
          snapshot.cropped_file
        ).and_return([false, 'z']).once

        expect(subject.send(:compare_element, element_meta)).to eq([false, 'z'])
      end
    end

    context 'file doesnt exist' do
      it 'calls resave_cropped_file and returns true result' do
        expect(DotDiff).to receive(:hide_elements_on_non_full_screen_screenshot).and_return(false)

        expect(snapshot).to receive(:capture_from_browser).with(false).once
        expect(snapshot).to receive(:crop_and_resave).with(element_meta).once
        expect(File).to receive(:exist?).with(snapshot.basefile).and_return(false)
        expect(snapshot).to receive(:resave_cropped_file).once

        expect(subject.send(:compare_element, element_meta)).to eq(
          [true, '/home/se/images/test.png']
        )
      end
    end
  end

  describe '#compare_page' do
    context 'file exists' do
      it 'calls compare with fullscreen file location' do
        expect(DotDiff).not_to receive(:hide_elements_on_non_full_screen_screenshot)

        expect(snapshot).to receive(:capture_from_browser).with(true).once
        expect(File).to receive(:exist?).with(snapshot.basefile).and_return(true)
        expect(subject).to receive(:compare).with(
          snapshot.fullscreen_file
        ).and_return([false, 'FAIL: haha']).once

        expect(subject.send(:compare_page)).to eq([false, 'FAIL: haha'])
      end
    end

    context 'file doesnt exist' do
      it 'calls resave_fullscreen_file and returns true result' do
        expect(DotDiff).not_to receive(:hide_elements_on_non_full_screen_screenshot)

        expect(snapshot).to receive(:capture_from_browser).with(true).once
        expect(snapshot).to receive(:resave_fullscreen_file).once
        expect(File).to receive(:exist?).with(snapshot.basefile).and_return(false)

        expect(subject.send(:compare_page)).to eq([true, '/home/se/images/test.png'])
      end
    end
  end

  describe '#compare' do
    context 'when resave_base_image is false' do
      let(:command_wrapper) { DotDiff::CommandWrapper.new }

      before do
        allow(DotDiff::CommandWrapper).to receive(:new).and_return(command_wrapper)
        command_wrapper.instance_variable_set('@ran_checks', true)
        command_wrapper.instance_variable_set('@failed', false)
      end

      context 'when images match' do
        before { allow(DotDiff).to receive(:failure_image_path).and_return(nil) }

        it 'calls command wrapper' do
          expect_any_instance_of(DotDiff::CommandWrapper).to receive(:run)
            .with('/home/se/images/test.png', '/tmp/new.png', '/images/test.diff.png').once

          expect(FileUtils).to receive(:mv).exactly(0).times
          expect(subject.send(:compare, '/tmp/new.png')).to eq [true, nil]
        end
      end

      context 'when the images dont match' do
        let(:diff_file) { '/tmp/fails/images/test.diff.png' }

        before do
          command_wrapper.instance_variable_set('@ran_checks', true)
          command_wrapper.instance_variable_set('@failed', true)
          command_wrapper.instance_variable_set('@message', 'FAILED: 120px pixel different')

          allow(DotDiff).to receive(:failure_image_path).and_return('/tmp/fails')
        end

        it 'returns false' do
          expect_any_instance_of(DotDiff::CommandWrapper).to receive(:run)
            .with('/home/se/images/test.png', '/tmp/new.png', diff_file).once

          expect(FileUtils).to receive(:mkdir_p).with('/tmp/fails/images').once
          expect(FileUtils).to receive(:mv)
            .with('/tmp/new.png', '/tmp/fails/images/test.new.png', force: true)

          expect(subject.send(:compare, '/tmp/new.png')).to eq(
            [false, 'FAILED: 120px pixel different']
          )
        end
      end
    end
  end
end
