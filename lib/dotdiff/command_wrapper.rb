# frozen_string_literal: true

require 'shellwords'

module DotDiff
  class CommandWrapper
    attr_reader :message, :pixels

    def run(base_image, new_image, diff_image_path)
      output = run_command(base_image, new_image, diff_image_path)
      @message = output

      begin
        @pixels = Float(output)
        @failed = false
      rescue ArgumentError
        @failed = true
      end
    end

    def passed?
      !failed?
    end

    def failed?
      @failed
    end

    private

    def run_command(base_image, new_image, diff_image_path)
      `#{command(base_image, new_image, diff_image_path)}`.strip
    end

    def command(base_image, new_image, diff_image_path)
      "#{DotDiff.image_magick_diff_bin} #{DotDiff.image_magick_options} " \
      "#{Shellwords.escape(base_image)} #{Shellwords.escape(new_image)} " \
      "#{Shellwords.escape(diff_image_path)} 2>&1"
    end
  end
end
