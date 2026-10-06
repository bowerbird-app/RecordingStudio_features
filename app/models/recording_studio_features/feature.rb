# frozen_string_literal: true

module RecordingStudioFeatures
  class Feature < ApplicationRecord
    self.table_name = "recording_studio_features"

    def self.declare_hierarchy!
      recording_studio_recordable label: "Feature",
                                  plural_label: "Features",
                                  root: false,
                                  allowed_parent_types: RecordingStudioFeatures.configuration.root_types
    end

    declare_hierarchy!

    include RecordingStudio::Capabilities::Attachable.to(
      allowed_content_types: ["image/*"],
      enabled_attachment_kinds: %i[image],
      max_file_count: 1
    )

    self.record_timestamps = false

    validates :title, presence: true

    before_validation :clear_blank_text
    before_create { self.created_at ||= Time.current }

    private

    def clear_blank_text
      self.subtitle = subtitle.presence
      self.description = description.presence
    end
  end
end
