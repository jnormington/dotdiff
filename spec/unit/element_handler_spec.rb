require 'spec_helper'

class MockDriver
  def execute_script(str)
  end

  def evaluate_script(str)
  end

  def all(x, f, args)
  end
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
      allow(subject).to receive(:elements_exists?).and_return(true)

      expect_any_instance_of(MockDriver).to receive(:execute_script).with(command1).once
      expect_any_instance_of(MockDriver).to receive(:execute_script).with(command2).once

      subject.hide
    end

    it 'doesnt call the set visibility when element doesnt exist' do
      allow(subject).to receive(:elements_exists?).and_return(false)

      expect_any_instance_of(MockDriver).not_to receive(:execute_script)
      expect_any_instance_of(MockDriver).not_to receive(:execute_script)

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
      allow(subject).to receive(:elements_exists?).and_return(true)

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
      allow(DotDiff).to receive(:xpath_elements_to_hide).and_return(['blah', 'blue'])
      expect(subject.elements).to eq ['blah', 'blue']
    end
  end

  describe '#elements_exists?' do
    before { allow(DotDiff).to receive(:max_wait_time).and_return(3) }

    it 'calls all with xpath' do
      expect_any_instance_of(MockDriver).to receive(:all)
        .with(:xpath, '//nav', wait: 3, visible: :all)
        .once
        .and_return([])

      subject.elements_exists?('//nav')
    end

    it 'returns true when there are elements found' do
      expect_any_instance_of(MockDriver).to receive(:all).and_return([1])

      expect(subject.elements_exists?('//nav')).to be true
    end

    it 'returns false when there are no elements found' do
      expect_any_instance_of(MockDriver).to receive(:all).and_return([])

      expect(subject.elements_exists?('//nav')).to be false
    end
  end
end
