# frozen_string_literal: true

require 'dotdiff/version'

require 'shellwords'
require 'tmpdir'
require 'fileutils'

require 'dotdiff/command_wrapper'
require 'dotdiff/element_handler'

require 'dotdiff/element_meta'
require 'dotdiff/image/cropper'
require 'dotdiff/snapshot'
require 'dotdiff/comparer'

module DotDiff
  class << self
    attr_accessor :failure_image_path, :image_store_path, :overwrite_on_resave

    attr_writer :image_magick_options, :pixel_threshold, :image_magick_diff_bin,
                :resave_base_image, :xpath_elements_to_hide, :hide_elements_on_non_full_screen_screenshot

    def configure
      yield self
    end

    def resave_base_image
      @resave_base_image ||= false
    end

    def xpath_elements_to_hide
      @xpath_elements_to_hide ||= []
    end

    def hide_elements_on_non_full_screen_screenshot
      @hide_elements_on_non_full_screen_screenshot ||= false
    end

    def image_magick_options
      @image_magick_options ||= '-fuzz 5% -metric AE'
    end

    def image_magick_diff_bin
      @image_magick_diff_bin.to_s.strip
    end

    def pixel_threshold
      @pixel_threshold ||= 100
    end
  end
end
