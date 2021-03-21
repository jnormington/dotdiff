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
        cmd = CommandWrapper.new
        cmd.run(snapshot.basefile, compare_to_image, snapshot.diff_file)

        return [cmd.passed?, cmd.message] if cmd.failed?

        calc = calculator(cmd.pixels)
        passed = calc.under_threshold?
        write_failure_imgs(compare_to_image) if !passed && DotDiff.failure_image_path

        [passed, calc.message]
      end

      def calculator(diff_pixels)
        DotDiff::ThresholdCalculator.new(
          DotDiff.pixel_threshold,
          basefile_pixels,
          diff_pixels
        )
      end

      def basefile_pixels
        img = Magick::Image.read(snapshot.basefile).first
        img.rows * img.columns
      end

      def write_failure_imgs(compare_to_image)
        FileUtils.mkdir_p(snapshot.failure_path)
        FileUtils.mv(compare_to_image, snapshot.new_file, force: true)
      end
    end
  end
end
