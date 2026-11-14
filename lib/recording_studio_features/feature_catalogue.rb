# frozen_string_literal: true

module RecordingStudioFeatures
  module FeatureCatalogue
    RECORDABLE_TYPE = "RecordingStudioFeatures::Feature"

    module_function

    def recordings_for(root)
      return RecordingStudio::Recording.none if root.blank?

      RecordingStudio::Recording.kept.where(
        recordable_type: RECORDABLE_TYPE,
        parent_recording_id: root.id
      )
    end
  end
end
