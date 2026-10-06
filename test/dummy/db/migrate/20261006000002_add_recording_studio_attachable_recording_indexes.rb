# frozen_string_literal: true

class AddRecordingStudioAttachableRecordingIndexes < ActiveRecord::Migration[8.1]
  def change
    return unless table_exists?(:recording_studio_recordings)

    unless index_exists?(:recording_studio_recordings, :parent_recording_id, name: "idx_rs_attachable_parent_active")
      add_index :recording_studio_recordings,
                :parent_recording_id,
                name: "idx_rs_attachable_parent_active",
                where: "recordable_type = 'RecordingStudioAttachable::Attachment' AND trashed_at IS NULL"
    end

    unless index_exists?(:recording_studio_recordings, :root_recording_id, name: "idx_rs_attachable_root_active")
      add_index :recording_studio_recordings,
                :root_recording_id,
                name: "idx_rs_attachable_root_active",
                where: "recordable_type = 'RecordingStudioAttachable::Attachment' AND trashed_at IS NULL"
    end
  end
end