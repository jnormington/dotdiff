module DotDiff
  class ElementHandler
    attr_accessor :driver

    def initialize(driver, elements = DotDiff.xpath_elements_to_hide)
      @driver = driver
      @elements = elements
    end

    def hide
      elements.each do |xpath|
        driver.execute_script(script(xpath, 'hidden')) if elements_exists?(xpath)
      end
    end

    def show
      elements.each do |xpath|
        driver.execute_script(script(xpath, '')) if elements_exists?(xpath)
      end
    end

    def script(xpath, visibility)
      xpath += if visibility == 'hidden'
        "[not(contains(@style, 'visibility'))]"
      else
        "[contains(@style, 'visibility: hidden')]"
      end

      # this is done like so instead of a single pass over all elements due to a bug in Firefox:
      # https://greasyfork.org/en/forum/discussion/12223/xpath-iteratenext-fails-in-firefox
      "var elem; while (elem = document.evaluate(\"#{xpath}\", document, "\
        'null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null).iterateNext()) '\
        "{ elem.style.visibility = '#{visibility}'; }"
    end

    def elements_exists?(xpath)
      driver.all(:xpath, xpath, wait: DotDiff.max_wait_time, visible: :all).any?
    end

    def elements
      @elements ||= []
    end
  end
end
