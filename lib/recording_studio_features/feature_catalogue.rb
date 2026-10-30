# frozen_string_literal: true

require "recording_studio_trashable/query"

module RecordingStudioFeatures
  module FeatureCatalogue
    RECORDABLE_TYPE = "RecordingStudioFeatures::Feature"

    module_function

    def recordings_for(root)
      return RecordingStudio::Recording.none if root.blank?

      relation = RecordingStudio::Recording.where(
        recordable_type: RECORDABLE_TYPE,
        parent_recording_id: root.id
      )
      keep_untrashed(relation)
    end

    def keep_untrashed(relation)
      return relation unless RecordingStudio::Recording.column_names.include?("trashed_at")

      relation.where(RecordingStudio::Recording.recording_studio_trashable_kept_sql)
    end
  end
end
