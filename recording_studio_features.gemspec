# frozen_string_literal: true

require_relative "lib/recording_studio_features/version"

Gem::Specification.new do |spec|
  spec.name        = "recording_studio_features"
  spec.version     = RecordingStudioFeatures::VERSION
  spec.authors     = ["Bowerbird"]
  spec.homepage    = "https://github.com/bowerbird-app/RecordingStudio_features"
  spec.summary     = "A descriptive catalogue of product features for Recording Studio"
  spec.description = "Recordable feature snapshots with a title, subtitle, description, and one image, " \
                     "listed in admin and exposed on the Recording Studio API."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bowerbird-app/RecordingStudio_features"
  spec.metadata["changelog_uri"] = "https://github.com/bowerbird-app/RecordingStudio_features/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"].reject do |path|
      path == ".cursor" || path.start_with?(".cursor/")
    end
  end

  spec.add_dependency "flat_pack", ">= 0.1.341"
  spec.add_dependency "rails", "~> 8.1.0"
  spec.add_dependency "recording_studio", ">= 7.0", "< 8.0"
  spec.add_dependency "recording_studio_accessible", ">= 0.44.0", "< 1.0"
  spec.add_dependency "recording_studio_admin", ">= 2.16.0"
  spec.add_dependency "recording_studio_api", ">= 0.24.0", "< 1.0"
  spec.add_dependency "recording_studio_attachable", ">= 0.28.0", "< 1.0"
  spec.add_dependency "recording_studio_moveable", ">= 5.0", "< 6.0"
  spec.add_dependency "recording_studio_trashable", ">= 0.17.0", "< 1.0"
end
