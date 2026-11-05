# frozen_string_literal: true

RecordingStudioFeatures.configure do |config|
  # Leave layout nil to follow RecordingStudio.configuration.layout, then
  # recording_studio/default_layout. Set a layout name, false, or
  # ->(controller:) { ... }.
  # config.layout = nil
end
