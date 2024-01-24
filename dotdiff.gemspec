# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dotdiff/version'

Gem::Specification.new do |spec|
  spec.name          = 'dotdiff'
  spec.version       = DotDiff::VERSION
  spec.authors       = ['Jon Normington']
  spec.email         = ['jnormington@users.noreply.github.com']

  spec.summary       = 'Image regression wrapper for Capybara and RSpec using image'\
                        'magick supporting both MRI and JRuby versions'
  spec.description   = [spec.summary, 'which supports snap shoting both full page and'\
                        "specific elements on a page where text checks isn't enough"].join(' ')
  spec.homepage      = 'https://github.com/jnormington/dotdiff'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'mini_magick', '>= 4.12.0'

  spec.add_development_dependency 'bundler', '>= 2'
  spec.add_development_dependency 'capybara', '>= 2.6'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '>= 3.0'
end
