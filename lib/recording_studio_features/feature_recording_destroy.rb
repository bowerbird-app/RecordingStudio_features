# frozen_string_literal: true

module RecordingStudioFeatures
  module FeatureRecordingDestroy
    # API destroy calls Recording#destroy!, and restrict_with_error blocks that
    # while an image attachment is still a child. Release those children first.
    def destroy!(...)
      if recordable_type == "RecordingStudioFeatures::Feature" &&
         !instance_variable_defined?(:@recording_studio_features_releasing)
        return RecordingStudioFeatures.release_and_destroy!(self)
      end

      super
    end
  end
end
