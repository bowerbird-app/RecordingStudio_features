# frozen_string_literal: true

module RecordingStudioFeatures
  module Admin
    module FeatureQueries
      private

      def feature_recording
        @feature_recording ||= feature_children.find(params[:id])
      end

      def feature_children
        RecordingStudioFeatures::FeatureCatalogue.recordings_for(current_feature_root)
      end

      def feature_parent
        root = current_feature_root
        return if root.blank?
        return unless RecordingStudioFeatures.configuration.root_types.include?(root.recordable_type)

        root
      end

      def current_feature_root
        if defined?(RecordingStudio::RootSwitchable)
          RecordingStudio::RootSwitchable.current_root_recording
        elsif respond_to?(:current_root_recording)
          current_root_recording
        end
      end

      def assign_shown_feature
        @feature = feature_recording.recordable
        @feature_recording = feature_recording
        @attachment_recording = image_attachment
      end

      def image_attachment
        RecordingStudioAttachable::AttachmentFileButton.attachment_recording_for(feature_recording)
      end

      def features_screen_path
        recording_studio_admin_context.admin_screen_path("recording_studio_features")
      end
    end
  end
end
