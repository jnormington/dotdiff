# frozen_string_literal: true

module DotDiff
  class ThresholdCalculator
    class UnknownTypeError < StandardError; end

    PIXEL = 'pixel'
    PERCENT = 'percent'

    def initialize(threshold_config, total_pixels, pixel_diff)
      @threshold_config = threshold_config
      @total_pixels = total_pixels
      @pixel_diff = pixel_diff
    end

    def under_threshold?
      return false if total_pixels.nil? || pixel_diff.nil?

      case threshold_type
      when PIXEL
        @value = pixel_diff
      when PERCENT
        @value = pixel_diff / total_pixels.to_f
      else
        raise UnknownTypeError, "Unable to handle threshold type: #{threshold_type}"
      end

      value <= threshold_value
    end

    def message
      "Outcome was '#{value}' difference for type '#{threshold_type}'"
    end

    private

    attr_reader :threshold_config, :pixel_diff, :total_pixels, :value

    def threshold_value
      return threshold_config if threshold_config.class == Integer

      threshold_config[:value]
    end

    def threshold_type
      return PIXEL if threshold_config.class != Hash

      threshold_config[:type].to_s
    end
  end
end
