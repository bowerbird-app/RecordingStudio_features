# frozen_string_literal: true

require "recording_studio"
require "recording_studio_accessible"
require "recording_studio_admin"
require "recording_studio_attachable"
require "recording_studio_features/version"
require "recording_studio_features/configuration"
require "recording_studio_features/engine"
require "recording_studio_features/api"
require "recording_studio_features/admin"
require "recording_studio_features/feature_recording_destroy"

module RecordingStudioFeatures
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
      sync_feature_parent_types!
    end

    def sync_feature_parent_types!(load_feature: false)
      const_get(:Feature) if load_feature
      return unless const_defined?(:Feature, false)

      Feature.declare_hierarchy!
    rescue NameError
      nil
    end

    def release_and_destroy!(recording)
      RecordingStudio::Recording.transaction do
        attachment_recordings_for(recording).each(&:destroy!)
        recording.instance_variable_set(:@recording_studio_features_releasing, true)
        recording.destroy!
      end
    end

    def install_feature_destroy!
      return unless defined?(RecordingStudio::Recording)
      return if RecordingStudio::Recording.ancestors.include?(FeatureRecordingDestroy)

      RecordingStudio::Recording.prepend(FeatureRecordingDestroy)
    end

    def attachment_recordings_for(recording)
      RecordingStudio::Recording.unscoped.where(
        parent_recording_id: recording.id,
        recordable_type: "RecordingStudioAttachable::Attachment"
      ).to_a
    end
  end
end

RecordingStudioFeatures.install_feature_destroy!
