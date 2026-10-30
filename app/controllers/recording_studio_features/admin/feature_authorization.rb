# frozen_string_literal: true

module RecordingStudioFeatures
  module Admin
    module FeatureAuthorization
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
    end
  end
end
