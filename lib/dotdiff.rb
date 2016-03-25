require 'dotdiff/version'

require 'shellwords'
require 'tmpdir'

require 'dotdiff/command_wrapper'
require 'dotdiff/image'
require 'dotdiff/element_handler'

require 'dotdiff/element_meta'
require 'dotdiff/image/cropper'
require 'dotdiff/snapshot'

module DotDiff
 class << self
   attr_accessor :perceptual_diff_bin, :resave_base_image, :failure_image_path,
                 :image_store_path, :overwrite_on_resave, :js_elements_to_hide

   def configure
     yield self
   end

   def resave_base_image
     @resave_base_image ||= false
   end

   def js_elements_to_hide
     @js_elements_to_hide ||= []
   end
 end
end
