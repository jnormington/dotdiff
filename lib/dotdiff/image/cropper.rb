# frozen_string_literal: true

require 'mini_magick'

module DotDiff
  module Image
    module Cropper
      def crop_and_resave(element)
        crop_left = element.rectangle.x.floor
        crop_right = (element.rectangle.x + element.rectangle.width).ceil
        crop_top = element.rectangle.y.floor
        crop_bottom = (element.rectangle.y + element.rectangle.height).ceil

        crop_width = crop_right - crop_left
        crop_height = crop_bottom - crop_top

        if crop_width - element.rectangle.width > 1
          crop_left += 1
          crop_width -= 1
        end
        if crop_height - element.rectangle.height > 1
          crop_top += 1
          crop_height -= 1
        end

        # @see https://www.imagemagick.org/script/command-line-options.php?#crop
        crop_area = "#{crop_width}x#{crop_height}+#{crop_left}+#{crop_top}"

        image = load_image(fullscreen_file)
        image.crop crop_area
        image.write(cropped_file)
      end

      def load_image(file)
        MiniMagick::Image.open(file)
      end
    end
  end
end
