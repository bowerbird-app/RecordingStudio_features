# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "flat_pack", github: "bowerbird-app/flatpack", tag: "v0.1.341"
gem "recording_studio", github: "bowerbird-app/RecordingStudio", tag: "v6.3.0"
gem "recording_studio_accessible", github: "bowerbird-app/RecordingStudio_accessible", tag: "v0.24.1"
gem "recording_studio_admin", github: "bowerbird-app/RecordingStudio_admin", tag: "v2.9.1"
gem "recording_studio_api", github: "bowerbird-app/RecordingStudio_api", tag: "v0.17.1"
gem "recording_studio_attachable", github: "bowerbird-app/RecordingStudio_attachable", tag: "v0.22.1"
# Required by admin >= 2.6 and api >= 0.14 (not on RubyGems)
gem "recording_studio_logs", github: "bowerbird-app/RecordingStudio_logs", tag: "v0.7.3",
                             require: false
# Required by attachable, admin, and api (not on RubyGems)
gem "recording_studio_metrics", github: "bowerbird-app/RecordingStudio_metrics", tag: "v0.7.2",
                                require: false
# Required by this gemspec and by admin (query helpers only; not on RubyGems)
gem "recording_studio_trashable", github: "bowerbird-app/RecordingStudio_trashable", tag: "v0.12.2",
                                  require: false
gem "redis", "~> 5.3"

gem "devise"
gem "puma"
gem "sprockets-rails"

group :development, :test do
  gem "debug"
  gem "minitest-mock"
  gem "simplecov", require: false
end

group :development do
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
end
