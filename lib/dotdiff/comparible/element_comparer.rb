# frozen_string_literal: true

module DotDiff
  module Comparible
    class ElementComparer < Base
      def run
        take_snapshot_and_crop

        if !File.exist?(snapshot.basefile)
          snapshot.resave_cropped_file
          [true, snapshot.basefile]
        else
          compare(snapshot.cropped_file)
        end
      end

      private

      def take_snapshot_and_crop
        snapshot.capture_from_browser(DotDiff.hide_elements_on_non_full_screen_screenshot)
        snapshot.crop_and_resave(element_meta)
      end
    end
  end
end
