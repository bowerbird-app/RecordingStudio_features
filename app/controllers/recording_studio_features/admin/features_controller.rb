# frozen_string_literal: true

module RecordingStudioFeatures
  module Admin
    class FeaturesController < ApplicationController # rubocop:disable Metrics/ClassLength
      include RecordingStudioAdmin::AdminActionAuditing if defined?(RecordingStudioAdmin::AdminActionAuditing)

      before_action :authenticate_user!, raise: false
      before_action :authorize_feature!

      rescue_from RecordingStudioAdmin::AuthorizationFailed, RecordingStudioAdmin::DefinitionNotFound do
        head :forbidden
      end

      def new
        assign_form(title: "", subtitle: "", description: "")
      end

      def create
        parent = feature_parent
        return render_missing_root if parent.blank?

        recording = write_feature!(:new, parent, audit_action: :create) do
          parent.record(Feature, actor: current_feature_actor) do |feature|
            feature.assign_attributes(feature_attributes)
          end
        end
        redirect_to admin_feature_path(recording), notice: "Feature saved."
      rescue ActiveRecord::RecordInvalid => e
        render_invalid(:new, e)
      end

      def show
        assign_shown_feature
      end

      def edit
        assign_shown_feature
        assign_form(
          title: @feature.title,
          subtitle: @feature.subtitle,
          description: @feature.description
        )
      end

      def update
        redirect_to admin_feature_path(revise_feature!), notice: "Feature saved."
      rescue ActiveRecord::RecordInvalid => e
        assign_shown_feature
        render_invalid(:edit, e)
      end

      def destroy
        write_feature!(:destroy, feature_recording, audit_action: :destroy) do
          feature_recording.destroy!
        end
        redirect_to features_screen_path, notice: "Feature removed."
      end

      private

      def authorize_feature!
        return head(:forbidden) unless defined?(RecordingStudioAdmin)

        RecordingStudioAdmin.authorize_resource!(
          key: "features",
          action: feature_resource_action,
          context: recording_studio_admin_context,
          record: feature_authorization_record,
          audit: true,
          audit_action: action_name
        )
      end

      def feature_resource_action
        case action_name
        when "create" then :new
        when "update" then :edit
        else action_name.to_sym
        end
      end

      def feature_authorization_record
        return if %w[new create].include?(action_name)

        feature_recording
      end

      def write_feature!(action, record, audit_action:)
        result = nil
        perform_recording_studio_admin_action!("features", action, record, audit_action: audit_action) do
          result = yield
          true
        end
        result
      end

      def recording_studio_admin_context
        return unless defined?(RecordingStudioAdmin::Context)

        @recording_studio_admin_context ||= RecordingStudioAdmin::Context.new(
          params: params.to_unsafe_h,
          current_actor: current_feature_actor,
          controller: self,
          routes: self,
          view_context: view_context
        )
      end

      def current_feature_actor
        return current_user if respond_to?(:current_user)

        Current.actor if defined?(Current)
      end

      def feature_recording
        @feature_recording ||= feature_children.find(params[:id])
      end

      def feature_children
        root = current_feature_root
        relation = RecordingStudio::Recording.where(
          recordable_type: Feature.name,
          parent_recording_id: root&.id
        )
        return relation.none if root.blank?
        return relation unless RecordingStudio::Recording.column_names.include?("trashed_at")

        relation.where(trashed_at: nil)
      end

      def feature_parent
        root = current_feature_root
        return if root.blank?
        return unless RecordingStudioFeatures.configuration.root_types.include?(root.recordable_type)

        root
      end

      def current_feature_root
        return unless respond_to?(:current_root_recording, true)

        send(:current_root_recording)
      end

      def revise_feature!
        write_feature!(:edit, feature_recording, audit_action: :update) do
          feature_recording.root_recording.revise(feature_recording, actor: current_feature_actor) do |feature|
            feature.assign_attributes(feature_attributes)
          end
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

      def render_missing_root
        flash.now[:alert] = "Features are saved under the admin root."
        assign_form_from_params
        render :new, status: :unprocessable_entity
      end

      def render_invalid(template, error)
        flash.now[:alert] = error.record.errors.full_messages.to_sentence.presence || "Check the feature and try again."
        assign_form_from_params
        render template, status: :unprocessable_entity
      end

      def assign_form_from_params
        assign_form(
          title: feature_params[:title],
          subtitle: feature_params[:subtitle],
          description: feature_params[:description]
        )
      end

      def assign_form(title:, subtitle:, description:)
        @title = title
        @subtitle = subtitle
        @description = description
      end

      def feature_attributes
        feature_params.to_h
      end

      def feature_params
        params.fetch(:feature, ActionController::Parameters.new).permit(:title, :subtitle, :description)
      end
    end
  end
end
