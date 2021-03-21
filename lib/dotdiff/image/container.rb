# frozen_string_literal: true

module DotDiff
  module Image
    class Container
      def initialize(baseimg_file, newimg_file)
        @baseimg_file = baseimg_file
        @newimg_file = newimg_file
      end

      def both_images_same_dimensions?
        base_image.rows == new_image.rows &&
          base_image.columns == new_image.columns
      end

      def total_pixels
        base_image.rows * base_image.columns
      end

      def dimensions_mismatch_msg
        <<~MSG
          Images are not the same dimensions to be compared
          Base file: #{base_image.columns}x#{base_image.rows}
          New file:  #{new_image.columns}x#{new_image.rows}
        MSG
      end

      private

      attr_reader :baseimg_file, :newimg_file

      def base_image
        @base_image ||= Magick::Image.read(baseimg_file).first
      end

      def new_image
        @new_image ||= Magick::Image.read(newimg_file).first
      end
    end
  end
end
