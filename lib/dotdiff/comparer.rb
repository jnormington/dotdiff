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
      snapshot.capture_from_browser
      snapshot.crop_and_resave(element_meta)

      if !File.exists?(snapshot.basefile)
        snapshot.resave_cropped_file
        [true, snapshot.basefile]
      else
        compare(snapshot.cropped_file)
      end
    end

    def compare_page
      snapshot.capture_from_browser

      if !File.exists?(snapshot.basefile)
        snapshot.resave_fullscreen_file
        [true, snapshot.basefile]
      else
        compare(snapshot.fullscreen_file)
      end
    end

    def compare(compare_to_image)
      result = CommandWrapper.new
      result.run(snapshot.basefile, compare_to_image)

      if result.failed? && DotDiff.failure_image_path
        failure_path = File.join(DotDiff.failure_image_path, snapshot.subdir)

        FileUtils.mkdir_p(failure_path)
        FileUtils.mv(compare_to_image, File.join(failure_path, snapshot.base_filename), force: true)
      end

      [result.passed?, result.message]
    end
  end
end
