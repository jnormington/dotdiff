# frozen_string_literal: true

module DotDiff
  module Comparible
    class Base
      def initialize(snapshot, element_meta)
        @snapshot = snapshot
        @element_meta = element_meta
      end

      def self.run(snapshot, element_meta)
        new(snapshot, element_meta).run
      end

      private

      attr_reader :snapshot, :element_meta

      def compare(compare_to_image)
        return [false, img_container.dimensions_mismatch_msg] unless img_container.both_images_same_dimensions?

        cmd = CommandWrapper.new
        cmd.run(snapshot.basefile, new_image_path, snapshot.diff_file)
        return [cmd.passed?, cmd.message] if cmd.failed?

        calculate_result(cmd.pixels)
      end

      def calculate_result(diff_pixels)
        calc = DotDiff::ThresholdCalculator.new(
          DotDiff.pixel_threshold,
          img_container.total_pixels,
          diff_pixels
        )

        [calc.under_threshold?, calc.message]
      end

      def img_container
        @img_container ||= DotDiff::Image::Container.new(
          snapshot.basefile,
          new_image_path
        )
      end
    end
  end
end
