# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DotDiff::ElementMeta do
  subject { DotDiff::ElementMeta.new(mock_page, mock_elem) }

  let(:mock_page) { MockPage.new }
  let(:mock_elem) { MockElement.new }

  describe '#initialize' do
    before { allow(mock_elem).to receive(:path).and_return('/html/body/div/form') }

    it 'assigns page and element to vars' do
      expect(subject.page).to eq mock_page
      expect(subject.element_xpath).to eq '/html/body/div/form'
    end
  end

  describe '#rectangle' do
    let(:xpath) { '/html/body/div/div/form' }

    it 'passes page object and xpath' do
      expect(mock_elem).to receive(:path).and_return(xpath).once
      expect(DotDiff::ElementMeta::Rectangle).to receive(:new).with(mock_page, xpath).once

      subject.rectangle
    end

    it 'returns a single instance of rectangle' do
      rect = subject.rectangle

      expect(rect).not_to be_nil
      expect(subject.rectangle).to eq rect
    end
  end

  describe DotDiff::ElementMeta::Rectangle do
    subject { DotDiff::ElementMeta::Rectangle.new(mock_page, rect) }

    let(:rect) do
      {
        'width' => 18.6, 'height' => 36.2, 'top' => 530.29,
        'right' => 66, 'bottom' => 566.2999877929688, 'left' => 48
      }
    end

    describe '#initialize' do
      it 'calls get_rect and assigns to the variable' do
        expect(mock_page).to receive(:evaluate_script).and_return(rect)

        subject = DotDiff::ElementMeta::Rectangle.new(mock_page, '//body/form')
        expect(subject.rect).to eq rect
      end
    end

    describe '#method_missing' do
      before { allow(subject).to receive(:rect).and_return(rect) }
      it 'raise exception when not a rect name' do
        expect { subject.haha }.to raise_error(NoMethodError)
      end

      it 'returns the rectangle size correctly' do
        expect(subject.x).to eq 48
        expect(subject.y).to eq 530.29
        expect(subject.width).to eq 18.6
        expect(subject.height).to eq 36.2
      end
    end

    describe '#js_query' do
      let(:xpath) { '/html/body/div/div/input' }

      it 'returns a string with xpath' do
        expect(subject.send(:js_query, xpath)).to eq(
          "document.evaluate(\"#{xpath}\", document, null, "\
          'XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.getBoundingClientRect()'
        )
      end
    end

    describe '#get_rect' do
      let(:xpath) { '/html/body/div/div/section' }

      it 'calls evaluate on page object with js script' do
        expect(subject).to receive(:js_query).and_return("document.evaluate(\"#{xpath}\")").once
        expect(mock_page).to receive(:evaluate_script).with("document.evaluate(\"#{xpath}\")").once

        subject.send(:get_rect, mock_page, xpath)
      end
    end
  end
end
