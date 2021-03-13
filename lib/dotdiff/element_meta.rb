# frozen_string_literal: true

module DotDiff
  class ElementMeta
    attr_reader :page, :element_xpath

    def initialize(page, element)
      @element_xpath = element.path
      @page = page
    end

    def rectangle
      @rectangle ||= Rectangle.new(@page, @element_xpath)
    end

    class Rectangle
      attr_reader :rect

      def initialize(page, xpath)
        @rect = get_rect(page, xpath)
      end

      def method_missing(name, *args, &block)
        if %w[x y width height].include?(name.to_s)
          case name
          when :x then rect['left']
          when :y then rect['top']
          else rect[name.to_s]
          end
        else
          super
        end
      end

      def respond_to_missing?(name, _include_private = false)
        %w[x y width height].include?(name.to_s) || super
      end

      private

      def js_query(xpath)
        "document.evaluate(\"#{xpath}\", document, null, XPathResult."\
        'FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.getBoundingClientRect()'
      end

      def get_rect(page, xpath)
        page.evaluate_script(js_query(xpath))
      end
    end
  end
end
