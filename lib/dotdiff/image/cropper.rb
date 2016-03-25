require 'chunky_png'

module DotDiff
  module Image
    module Cropper
      def crop_and_resave(element)
        image = load_image(fullscreen_file)

        image.crop!(
          element.rectangle.x,
          element.rectangle.y,
          element.rectangle.width,
          element.rectangle.height
        )

        image.save(cropped_file)
      end

      def load_image(image_file)
        ::ChunkyPNG::Image.from_file(image_file)
      end
    end
  end
end
