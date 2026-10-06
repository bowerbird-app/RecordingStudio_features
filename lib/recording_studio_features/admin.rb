# frozen_string_literal: true

require "recording_studio_admin"

module RecordingStudioFeatures
  module Admin
    class FeaturesSection < RecordingStudioAdmin::Section
      key "features"
      title "Features"
      subtitle "Titles, descriptions, and images."
      blast_radius :root

      link :catalogue,
           text: "Features",
           url: ->(context) { context.admin_screen_path("recording_studio_features") },
           style: :secondary
      link :new,
           text: "New",
           url: ->(_context) { RecordingStudioFeatures.admin_new_feature_path },
           style: :primary
    end

    class FeaturesScreen < RecordingStudioAdmin::Screen
      key "recording_studio_features"
      title "Features"
      subtitle "What this product does."
      blast_radius :root
      query do |context|
        root = context.root_recording
        next RecordingStudio::Recording.none if root.blank?

        relation = RecordingStudio::Recording.where(
          recordable_type: "RecordingStudioFeatures::Feature",
          parent_recording_id: root.id
        )
        relation = relation.where(trashed_at: nil) if RecordingStudio::Recording.column_names.include?("trashed_at")
        relation.includes(:recordable).order(updated_at: :desc)
      end

      table do
        title "Features"
        column :title,
               title: "Title",
               sortable: false,
               value: ->(recording, _context) { recording.recordable&.title }
        column :subtitle,
               title: "Subtitle",
               sortable: false,
               value: ->(recording, _context) { recording.recordable&.subtitle }
        column :updated_at, title: "Updated"
        admin_action "features.show", as: :open
        admin_action "features.edit"
        admin_action "features.destroy"
      end
    end

    class FeaturesResource < RecordingStudioAdmin::Resource
      key "features"
      section "features"
      title "Features"
      blast_radius :root

      action :show,
             text: "Show",
             url: ->(recording, _context) { RecordingStudioFeatures.admin_feature_path(recording) if recording },
             visible_if: ->(recording, _context) { recording.present? }

      action :edit,
             text: "Edit",
             required_role: :edit,
             url: lambda { |recording, _context|
               RecordingStudioFeatures.edit_admin_feature_path(recording) if recording
             },
             visible_if: ->(recording, _context) { recording.present? }

      action :destroy,
             text: "Remove",
             method: :delete,
             destructive: true,
             required_role: :admin,
             confirm: "Remove this feature?",
             url: ->(recording, _context) { RecordingStudioFeatures.admin_feature_path(recording) if recording },
             visible_if: ->(recording, _context) { recording.present? }

      action :new,
             text: "New",
             required_role: :edit,
             url: ->(_recording, _context) { RecordingStudioFeatures.admin_new_feature_path }
    end

    def self.register!
      RecordingStudioAdmin.register_section(FeaturesSection)
      RecordingStudioAdmin.register_screen(FeaturesScreen)
      RecordingStudioAdmin.register_resource(FeaturesResource)
    end
  end

  def self.admin_features_path
    engine_admin_path(:admin_features_path)
  end

  def self.admin_new_feature_path
    engine_admin_path(:new_admin_feature_path)
  end

  def self.admin_feature_path(recording)
    engine_admin_path(:admin_feature_path, recording)
  end

  def self.edit_admin_feature_path(recording)
    engine_admin_path(:edit_admin_feature_path, recording)
  end

  def self.engine_admin_path(helper, *)
    Engine.routes.url_helpers.public_send(helper, *, script_name: configuration.mount_path)
  end
  private_class_method :engine_admin_path
end
