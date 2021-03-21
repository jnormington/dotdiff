# Dotdiff

Dotdiff is a very basic wrapper around imåge magick compare program which works with both Capybara
and RSpec to capture and compare the images with a simple rspec matcher.

It is now also possible to snapshot a particular element on the page just by using the standard
capybara finders - which once the element is found will query the browser for its dimensions and
placement on the page and use that metadata to crop using chunky_png from a full page snapshot.

It can also hide certain elements via executing javascript for elements which can change with
different display suchas username or user specific details, but only for full page screenshots.

## Installation


Add this line to your application's Gemfile:

This is the same for JRuby platform as well (both MRI and JRuby versions of gem is uploaded)

```ruby
gem 'dotdiff'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dotdiff


## Usage

### Dependencies
First ensure to install image magick binary which is available via apt-get or brew

In your spec/spec_helper
```
require 'dotdiff'
```

If you want the rspec_matcher require the following as well
```
require 'dotdiff/rspec_matcher'
```

### Configuration
In an initializer you can configure certain options example shown below within Dotdiff

```ruby
DotDiff.configure do |config|
  config.image_magick_diff_bin = `which compare`
  config.pixel_threshold = { type: 'percent', value: 0.04 }
  config.image_magick_options = '-metric AE'
  config.image_store_path = File.join('/home', 'user', 'images')
  config.xpath_elements_to_hide = ["id('main')"]
  config.hide_elements_on_non_full_screen_screenshot = true
  config.failure_image_path = File.join('/home', 'user', 'failure_comparisions')
end
```

### Spec usage

For a full page screenshot you can use the below;

```ruby
expect(page).to match_image('HomePage', subdir: 'Normitec')
```

For a specific element screenshot you can use like so;

```ruby
expect(find('#login-form')).to match_image('LoginForm', subdir: 'Normitec')
```

The only difference for the element specific is passing a specific element in the `expect` parameter.

## Configuration Options

| Config                 | Description                                                                                                                                                                                                                                                                                                                                                                                                                                         | Example                                               | Default                        | Required |
|------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------|--------------------------------|----------|
| image_magick_diff_bin    | Location of the image magick compare binary file                                                                                                                                                                                                                                                                                                                                                                                                         | `which compare`                          | N/A                            | Yes      |
| image_store_path       | The root path to store the base images                                                                                                                                                                                                                                                                                                                                                                                                              | File.join('/home', 'user','images')                   | nil                            | Yes      |
| xpath_elements_to_hide | When taking full page screenshots it will hide elements specified that might change each time and re-shows them after the screenshot.  It doesn't use this option for taking screenshots of specific elements.                                                                                                                                                                                                                                      | ["id('main')", "//div[contains(@class, 'formy'])[1]"] | []                             | No       |
| hide_elements_on_non_full_screen_screenshot | When taking non full page screenshots whether to also hide elements using `xpath_elements_to_hide` or not hide anything at all                                                                                    | true | false                             | No       |
| failure_image_path     | When a comparison occurs and the perceptual_diff binary returns a failure with the message. It will dump the new image taken for comparison to this directory.  If not supplied it will not move the images from the temporary location that it is generated at.                                                                                                                                                                                    | File.join('/home', 'user','failures')                 | nil                            | No       |
| pixel_threshold       |  This validates the output from compare is within your specified threshold_config which supports pixel or percent value | { type: 'percent', value: 0.03 } | { type: 'pixel', value: 100 } | No      |
| image_magick_options  |  This allows you to pass some custom options to image magick    | '-fuzz 10% -metric RSME'  | '-fuzz 5% -metric AE'  | No      |

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jnormington/dotdiff.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Whats still to do

Its not fully completed yet but is usable in its current state.
 - Improve the message output to extract just the fail line
 - Add an integration spec
