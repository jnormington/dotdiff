# frozen_string_literal: true

require 'spec_helper'

class MockDriver
  def execute_script(str); end

  def evaluate_script(str); end
end

RSpec.describe 'DotDiff::ElementHandler' do
  subject { DotDiff::ElementHandler.new(MockDriver.new) }

  before do
    allow(DotDiff).to receive(:xpath_elements_to_hide).and_return([
                                                                    "//nav[@class='master-opt']",
                                                                    "id('user-links')"
                                                                  ])
  end

  describe '#hide' do
    let(:command1) do
      "var elem; while (elem = document.evaluate(\"//nav[@class='master-opt']"\
        "[not(contains(@style, 'visibility'))]\", document, "\
        'null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null).iterateNext()) '\
        "{ elem.style.visibility = 'hidden'; }"
    end

    let(:command2) do
      "var elem; while (elem = document.evaluate(\"id('user-links')"\
        "[not(contains(@style, 'visibility'))]\", document, "\
        'null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null).iterateNext()) '\
        "{ elem.style.visibility = 'hidden'; }"
    end

    it 'calls execute_script setting the visibility to hidden' do
      expect_any_instance_of(MockDriver).to receive(:execute_script).with(command1).once
      expect_any_instance_of(MockDriver).to receive(:execute_script).with(command2).once

      subject.hide
    end
  end

  describe '#show' do
    let(:command1) do
      "var elem; while (elem = document.evaluate(\"//nav[@class='master-opt']"\
        "[contains(@style, 'visibility: hidden')]\", document, "\
        'null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null).iterateNext()) '\
        "{ elem.style.visibility = ''; }"
    end

    let(:command2) do
      "var elem; while (elem = document.evaluate(\"id('user-links')"\
        "[contains(@style, 'visibility: hidden')]\", document, "\
        'null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null).iterateNext()) '\
        "{ elem.style.visibility = ''; }"
    end

    it 'calls execute_script when setting the visibility to show' do
      expect_any_instance_of(MockDriver).to receive(:execute_script).with(command1).once
      expect_any_instance_of(MockDriver).to receive(:execute_script).with(command2).once

      subject.show
    end
  end

  describe '#elements' do
    it 'returns an empty array when not set' do
      allow(DotDiff).to receive(:xpath_elements_to_hide).and_return(nil)
      expect(subject.elements).to eq []
    end

    it 'returns the user set value xpath_elements_to_hide' do
      allow(DotDiff).to receive(:xpath_elements_to_hide).and_return(%w[blah blue])
      expect(subject.elements).to eq %w[blah blue]
    end
  end
end
