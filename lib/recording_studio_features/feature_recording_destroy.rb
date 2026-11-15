# frozen_string_literal: true

module RecordingStudioFeatures
  module FeatureRecordingDestroy
    # API and admin destroy call Recording#destroy!. Core 7 still declares
    # child_recordings dependent: :restrict_with_error, so an image attachment
    # still blocks that. Release those children first. Trashable does not
    # override destroy!.
    def destroy!(...)
      if recordable_type == "RecordingStudioFeatures::Feature" &&
         !instance_variable_defined?(:@recording_studio_features_releasing)
        return RecordingStudioFeatures.release_and_destroy!(self)
      end

      super
    end
  end
end
