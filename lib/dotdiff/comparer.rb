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
      comparer = build_comparer

      if comparer.nil?
        raise ArgumentError, "Unknown element class received: #{element.class.name}"
      end

      passed, msg = comparer.run
      write_failure_imgs(comparer.new_image_path) if !passed && DotDiff.failure_image_path

      [passed, msg]
    end

    private

    def write_failure_imgs(new_image_path)
      FileUtils.mkdir_p(snapshot.failure_path)
      FileUtils.mv(new_image_path, snapshot.new_file, force: true)
    end

    def build_comparer
      if element.is_a?(Capybara::Session)
        DotDiff::Comparible::PageComparer.new(snapshot, nil)
      elsif element.is_a?(Capybara::Node::Base)
        DotDiff::Comparible::ElementComparer.new(snapshot, ElementMeta.new(page, element))
      end
    end
  end
end
