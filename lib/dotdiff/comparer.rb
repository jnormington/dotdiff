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
        compare_page
      elsif element.is_a?(Capybara::Node::Base)
        compare_element
      else
        raise ArgumentError, "Unknown element class received: #{element.class.name}"
      end
    end

    private

    def compare_element(element_meta = ElementMeta.new(page, element))
      snapshot.capture_from_browser(DotDiff.hide_elements_on_non_full_screen_screenshot)
      snapshot.crop_and_resave(element_meta)

      if !File.exist?(snapshot.basefile)
        snapshot.resave_cropped_file
        [true, snapshot.basefile]
      else
        compare(snapshot.cropped_file)
      end
    end

    def compare_page
      snapshot.capture_from_browser(true)

      if !File.exist?(snapshot.basefile)
        snapshot.resave_fullscreen_file
        [true, snapshot.basefile]
      else
        compare(snapshot.fullscreen_file)
      end
    end

    def compare(compare_to_image)
      result = CommandWrapper.new
      result.run(snapshot.basefile, compare_to_image, snapshot.diff_file)

      if result.failed? && DotDiff.failure_image_path
        FileUtils.mkdir_p(snapshot.failure_path)
        FileUtils.mv(compare_to_image, snapshot.new_file, force: true)
      end

      [result.passed?, result.message]
    end
  end
end
