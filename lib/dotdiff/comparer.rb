# frozen_string_literal: true

module DotDiff
  class Comparer
    attr_reader :element, :page, :snapshot

    def initialize(element, page, snapshot)
      @page = page
      @element = element
      @snapshot = snapshot
    end

    def result
      if element.is_a?(Capybara::Session)
        DotDiff::Comparible::PageComparer.run(snapshot, nil)
      elsif element.is_a?(Capybara::Node::Base)
        DotDiff::Comparible::ElementComparer.run(snapshot, ElementMeta.new(page, element))
      else
        raise ArgumentError, "Unknown element class received: #{element.class.name}"
      end
    end
  end
end
