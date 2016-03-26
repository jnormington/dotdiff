require 'spec_helper'

class MockDriver
  def execute_script(str)
  end

  def evaluate_script(str)
  end

  def find(x,f, args)
  end
end

RSpec.describe 'DotDiff::ElementHandler' do
  subject { DotDiff::ElementHandler.new(MockDriver.new) }

  before do
    allow(DotDiff).to receive(:js_elements_to_hide).and_return([
      "//nav[@class='master-opt']",
      "id('user-links')"
    ])
  end

  describe '#hide' do
    let(:command1) do
      "document.evaluate(\"//nav[@class='master-opt']\", document, null"\
      ", XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.style.visibility = 'hidden'"
    end

    let(:command2) do
      "document.evaluate(\"id('user-links')\", document, null"\
      ", XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.style.visibility = 'hidden'"
    end

    it 'calls execute_script setting the visibility to hidden' do
      allow(subject).to receive(:element_exists?).and_return(true)

      expect_any_instance_of(MockDriver).to receive(:execute_script).with(command1).once
      expect_any_instance_of(MockDriver).to receive(:execute_script).with(command2).once

      subject.hide
    end

    it 'doesnt call the set visibility when element doesnt exist' do
      allow(subject).to receive(:element_exists?).and_return(false)

      expect_any_instance_of(MockDriver).not_to receive(:execute_script)
      expect_any_instance_of(MockDriver).not_to receive(:execute_script)

      subject.hide
    end
  end

  describe '#show' do
    let(:command1) do
      "document.evaluate(\"//nav[@class='master-opt']\", document, null"\
      ", XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.style.visibility = ''"
    end

    let(:command2) do
      "document.evaluate(\"id('user-links')\", document, null"\
      ", XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.style.visibility = ''"
    end

    it 'calls execute_script when setting the visibility to show' do
      allow(subject).to receive(:element_exists?).and_return(true)

      expect_any_instance_of(MockDriver).to receive(:execute_script).with(command1).once
      expect_any_instance_of(MockDriver).to receive(:execute_script).with(command2).once

      subject.show
    end
  end

  describe '#elements' do
    it 'returns an empty array when not set' do
      allow(DotDiff).to receive(:js_elements_to_hide).and_return(nil)
      expect(subject.elements).to eq []
    end

    it 'returns the user set value js_elements_to_hide' do
      allow(DotDiff).to receive(:js_elements_to_hide).and_return(['blah', 'blue'])
      expect(subject.elements).to eq ['blah', 'blue']
    end
  end

  describe '#element_exists?' do
    before { allow(DotDiff).to receive(:max_wait_time).and_return(3) }
    it 'calls find with xpath' do
      expect_any_instance_of(MockDriver).to receive(:find)
        .with(:xpath, '//nav', wait: 3, visible: :all).once

      subject.element_exists?('//nav')
    end
  end
end
