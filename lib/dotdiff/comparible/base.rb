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

      attr_reader :snapshot, :element_meta, :new_image

      def compare(compare_to_image)
        @new_image = compare_to_image
        return [false, img_container.dimensions_mismatch_msg] unless img_container.both_images_same_dimensions?

        cmd = CommandWrapper.new
        cmd.run(snapshot.basefile, new_image, snapshot.diff_file)
        return [cmd.passed?, cmd.message] if cmd.failed?

        calculate_result(cmd.pixels)
      end

      def calculate_result(diff_pixels)
        calc = DotDiff::ThresholdCalculator.new(
          DotDiff.pixel_threshold,
          img_container.total_pixels,
          diff_pixels
        )

        passed = calc.under_threshold?
        write_failure_imgs if !passed && DotDiff.failure_image_path

        [passed, calc.message]
      end

      def img_container
        @img_container ||= DotDiff::Image::Container.new(
          snapshot.basefile,
          new_image
        )
      end

      def write_failure_imgs
        FileUtils.mkdir_p(snapshot.failure_path)
        FileUtils.mv(new_image, snapshot.new_file, force: true)
      end
    end
  end
end
