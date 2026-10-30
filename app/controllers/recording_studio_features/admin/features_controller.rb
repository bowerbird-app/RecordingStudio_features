# frozen_string_literal: true

module RecordingStudioFeatures
  module Admin
    class FeaturesController < ApplicationController
      include RecordingStudioAdmin::AdminActionAuditing if defined?(RecordingStudioAdmin::AdminActionAuditing)
      include FeatureAuthorization
      include FeatureWrites
      include FeatureQueries

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
    end
  end
end
