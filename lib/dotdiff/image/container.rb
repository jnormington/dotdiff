# frozen_string_literal: true

module DotDiff
  module Image
    class Container
      def initialize(baseimg_file, newimg_file)
        @baseimg_file = baseimg_file
        @newimg_file = newimg_file
      end

      def both_images_same_dimensions?
        base_image.width == new_image.width &&
          base_image.height == new_image.height
      end

      def total_pixels
        base_image.width * base_image.height
      end

      def dimensions_mismatch_msg
        <<~MSG
          Images are not the same dimensions to be compared
          Base file: #{base_image.width}x#{base_image.height}
          New file:  #{new_image.width}x#{new_image.height}
        MSG
      end

      private

      attr_reader :baseimg_file, :newimg_file

      def base_image
        @base_image ||= MiniMagick::Image.open(baseimg_file)
      end

      def new_image
        @new_image ||= MiniMagick::Image.open(newimg_file)
      end
    end
  end
end
