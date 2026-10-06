# frozen_string_literal: true

module RecordingStudioFeatures
  class Engine < ::Rails::Engine
    isolate_namespace RecordingStudioFeatures

    class << self
      def apply_model_extensions(target)
        apply_extensions(target, extensions_for(:model, extension_keys_for(target)))
      end

      def apply_controller_extensions(target)
        apply_extensions(target, extensions_for(:controller, extension_keys_for(target)))
      end

      private

      def extensions_for(kind, names)
        hooks = RecordingStudioFeatures.configuration.hooks
        Array(names).flat_map do |name|
          if kind == :model
            hooks.model_extensions_for(name)
          else
            hooks.controller_extensions_for(name)
          end
        end
      end

      def apply_extensions(target, extensions)
        return unless target

        applied = target.instance_variable_get(:@recording_studio_features_applied_extensions) || identity_hash

        extensions.flatten.compact.each do |extension|
          next if applied[extension]

          target.class_eval(&extension)
          applied[extension] = true
        end

        target.instance_variable_set(:@recording_studio_features_applied_extensions, applied)
      end

      def extension_keys_for(target)
        names = [target.name, target.name&.demodulize].compact.uniq
        names.map(&:to_sym)
      end

      def identity_hash
        {}.compare_by_identity
      end
    end

    initializer "recording_studio_features.before_initialize", before: "recording_studio_features.load_config" do |_app|
      RecordingStudioFeatures.configuration.hooks.run(:before_initialize, self)
    end

    initializer "recording_studio_features.load_config" do |app|
      RecordingStudioFeatures.configuration.load_from_rails_app!(app)
      RecordingStudioFeatures.configuration.hooks.run(:on_configuration, RecordingStudioFeatures.configuration)
    end

    initializer "recording_studio_features.after_initialize", after: "recording_studio_features.load_config" do |_app|
      RecordingStudioFeatures.configuration.hooks.run(:after_initialize, self)
    end

    initializer "recording_studio_features.api", after: "recording_studio_features.after_initialize" do
      config.after_initialize do
        next unless defined?(RecordingStudioApi)

        RecordingStudioFeatures::Api.register!(api: :public)
      end
    end

    initializer "recording_studio_features.admin_definitions" do
      config.to_prepare { RecordingStudioFeatures::Admin.register! }
    end

    initializer "recording_studio_features.sync_parent_types" do
      config.to_prepare { RecordingStudioFeatures.sync_feature_parent_types!(load_feature: true) }
    end

    initializer "recording_studio_features.feature_destroy" do
      config.to_prepare { RecordingStudioFeatures.install_feature_destroy! }
    end

    initializer "recording_studio_features.apply_model_extensions" do
      config.to_prepare do
        next unless defined?(ActiveRecord::Base)

        ActiveRecord::Base.descendants.each do |model|
          next if model.abstract_class?

          RecordingStudioFeatures::Engine.apply_model_extensions(model)
        end
      end
    end

    initializer "recording_studio_features.apply_controller_extensions" do
      config.to_prepare do
        next unless defined?(ActionController::Base)

        ActionController::Base.descendants.each do |controller|
          RecordingStudioFeatures::Engine.apply_controller_extensions(controller)
        end
      end
    end
  end
end
