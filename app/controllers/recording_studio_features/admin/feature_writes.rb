# frozen_string_literal: true

module RecordingStudioFeatures
  module Admin
    module FeatureWrites
      private

      def write_feature!(action, record, audit_action:)
        result = nil
        perform_recording_studio_admin_action!("features", action, record, audit_action: audit_action) do
          result = yield
          true
        end
        result
      end

      def current_feature_actor
        return current_user if respond_to?(:current_user)

        Current.actor if defined?(Current)
      end

      def revise_feature!
        write_feature!(:edit, feature_recording, audit_action: :update) do
          feature_recording.root_recording.revise(feature_recording, actor: current_feature_actor) do |feature|
            feature.assign_attributes(feature_attributes)
          end
        end
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
