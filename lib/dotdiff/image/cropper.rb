# frozen_string_literal: true

require 'rmagick'

module DotDiff
  module Image
    module Cropper
      def crop_and_resave(element)
        image = load_image(fullscreen_file)
        image.crop!(
          element.rectangle.x.floor,
          element.rectangle.y.floor,
          width(element, image),
          height(element, image)
        )

        image.write(cropped_file)
      end

      def load_image(file)
        Magick::Image.read(file).first
      end

      def height(element, image)
        element_height = element.rectangle.height + element.rectangle.y
        image_height = image.rows

        if element_height > image_height
          image_height - element.rectangle.y
        else
          element.rectangle.height
        end
      end

      def width(element, image)
        element_width = element.rectangle.width + element.rectangle.x
        image_width = image.columns

        if element_width > image_width
          image_width - element.rectangle.x
        else
          element.rectangle.width
        end
      end
    end
  end
end
