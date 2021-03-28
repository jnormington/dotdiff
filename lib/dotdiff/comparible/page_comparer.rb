# frozen_string_literal: true

module DotDiff
  module Comparible
    class PageComparer < Base
      def run
        snapshot.capture_from_browser(true)

        if !File.exist?(snapshot.basefile)
          snapshot.resave_fullscreen_file
          [true, snapshot.basefile]
        else
          compare(snapshot.fullscreen_file)
        end
      end

      def new_image_path
        snapshot.fullscreen_file
      end
    end
  end
end
