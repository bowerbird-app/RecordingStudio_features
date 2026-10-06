# frozen_string_literal: true

RecordingStudioFeatures.configure do |config|
  config.root_types = ["AdminRoot"]
  config.mount_path = "/recording_studio_features"
end
