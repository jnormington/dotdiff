# frozen_string_literal: true

require 'mini_magick'

module DotDiff
  module Image
    module Cropper
      def crop_and_resave(element)
        image = load_image(fullscreen_file)

        # @see http://www.imagemagick.org/script/command-line-options.php?#crop
        crop_area =
          '' + width(element, image).to_s +
          'x' + height(element, image).to_s +
          '+' + element.rectangle.x.floor.to_s +
          '+' + element.rectangle.y.floor.to_s

        image.crop crop_area
        image.write(cropped_file)
      end

      def load_image(file)
        MiniMagick::Image.open(file)
      end

      def height(element, image)
        element_height = element.rectangle.height + element.rectangle.y
        image_height = image.height

        if element_height > image_height
          image_height - element.rectangle.y
        else
          element.rectangle.height
        end
      end

      def width(element, image)
        element_width = element.rectangle.width + element.rectangle.x
        image_width = image.width

        if element_width > image_width
          image_width - element.rectangle.x
        else
          element.rectangle.width
        end
      end
    end
  end
end
