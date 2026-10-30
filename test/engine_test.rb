# frozen_string_literal: true

require "test_helper"

class EngineTest < Minitest::Test
  def setup
    @original_configuration = RecordingStudioFeatures.configuration
    RecordingStudioFeatures.reset_configuration!
  end

  def teardown
    RecordingStudioFeatures.configuration.hooks.clear!
    RecordingStudioFeatures.configuration = @original_configuration
  end

  def test_before_and_after_initialize_initializers_run_hooks
    before_called = false
    after_called = false

    RecordingStudioFeatures.configuration.hooks.before_initialize { |_engine| before_called = true }
    RecordingStudioFeatures.configuration.hooks.after_initialize { |_engine| after_called = true }

    find_initializer("recording_studio_features.before_initialize").block.call(Object.new)
    find_initializer("recording_studio_features.after_initialize").block.call(Object.new)

    assert before_called
    assert after_called
  end

  def test_load_config_merges_config_sources_and_runs_on_configuration_hook
    hook_called = false
    hook_payload = nil
    RecordingStudioFeatures.configuration.hooks.on_configuration do |cfg|
      hook_called = true
      hook_payload = cfg
    end

    xcfg = Struct.new(:recording_studio_features).new({ mount_path: "/from-x" })
    app_config = Struct.new(:x).new(xcfg)
    app = Struct.new(:config) do
      def config_for(_name)
        { root_types: ["Workspace"], mount_path: "/from-yaml" }
      end
    end.new(app_config)

    find_initializer("recording_studio_features.load_config").block.call(app)

    assert hook_called
    assert_equal RecordingStudioFeatures.configuration, hook_payload
    assert_equal ["Workspace"], RecordingStudioFeatures.configuration.root_types
    assert_equal "/from-x", RecordingStudioFeatures.configuration.mount_path
  end

  def test_load_config_handles_missing_yaml_and_each_pair_fallback
    pair_config = Class.new do
      def each_pair
        yield(:mount_path, "/from-pair")
      end
    end.new

    xcfg = Struct.new(:recording_studio_features).new(pair_config)
    app_config = Struct.new(:x).new(xcfg)

    app = Struct.new(:config) do
      def config_for(_name)
        raise "Could not load configuration. No such file - config/recording_studio_features.yml"
      end
    end.new(app_config)

    find_initializer("recording_studio_features.load_config").block.call(app)

    assert_equal "/from-pair", RecordingStudioFeatures.configuration.mount_path
  end

  def test_load_config_does_not_swallow_each_pair_errors
    bad_pair_config = Class.new do
      def each_pair
        raise "bad pair"
      end
    end.new

    xcfg = Struct.new(:recording_studio_features).new(bad_pair_config)
    app_config = Struct.new(:x).new(xcfg)
    app = Struct.new(:config) do
      def config_for(_name)
        { mount_path: "/from-yaml" }
      end
    end.new(app_config)

    error = assert_raises(RuntimeError) do
      find_initializer("recording_studio_features.load_config").block.call(app)
    end

    assert_equal "bad pair", error.message
    assert_equal "/from-yaml", RecordingStudioFeatures.configuration.mount_path
  end

  def test_load_config_is_noop_without_config_sources
    app = Struct.new(:config).new(Object.new)

    find_initializer("recording_studio_features.load_config").block.call(app)

    assert_equal ["AdminRoot"], RecordingStudioFeatures.configuration.root_types
    assert_equal "/recording_studio_features", RecordingStudioFeatures.configuration.mount_path
  end

  def test_load_config_ignores_non_enumerable_yaml
    yaml = Object.new
    xcfg = Struct.new(:recording_studio_features).new({ mount_path: "/from-x" })
    app_config = Struct.new(:x).new(xcfg)
    app = Struct.new(:config) do
      attr_accessor :yaml

      def config_for(_name)
        @yaml
      end
    end.new(app_config)
    app.yaml = yaml

    find_initializer("recording_studio_features.load_config").block.call(app)

    assert_equal "/from-x", RecordingStudioFeatures.configuration.mount_path
  end

  def test_load_config_does_not_swallow_yaml_each_errors
    yaml = Class.new do
      def each
        raise "bad yaml"
      end
    end.new

    xcfg = Struct.new(:recording_studio_features).new({ mount_path: "/from-x" })
    app_config = Struct.new(:x).new(xcfg)
    app = Struct.new(:config) do
      attr_accessor :yaml

      def config_for(_name)
        @yaml
      end
    end.new(app_config)
    app.yaml = yaml

    error = assert_raises(RuntimeError) do
      find_initializer("recording_studio_features.load_config").block.call(app)
    end

    assert_equal "bad yaml", error.message
  end

  def test_load_config_swallows_psych_errors_from_yaml
    xcfg = Struct.new(:recording_studio_features).new({ mount_path: "/from-x" })
    app_config = Struct.new(:x).new(xcfg)
    app = Struct.new(:config) do
      def config_for(_name)
        raise Psych::SyntaxError.new("file.yml", 1, 1, 0, "bad yaml", nil)
      end
    end.new(app_config)

    find_initializer("recording_studio_features.load_config").block.call(app)

    assert_equal "/from-x", RecordingStudioFeatures.configuration.mount_path
  end

  def test_apply_extension_initializers_register_active_support_on_load_callbacks
    to_prepare_blocks = []
    config_stub = Object.new
    config_stub.define_singleton_method(:to_prepare) do |&block|
      to_prepare_blocks << block
    end

    RecordingStudioFeatures::Engine.stub(:config, config_stub) do
      find_initializer("recording_studio_features.apply_model_extensions").block.call
      find_initializer("recording_studio_features.apply_controller_extensions").block.call
    end

    assert_equal 2, to_prepare_blocks.size
  end

  def test_model_extension_initializer_skips_abstract_models
    to_prepare_blocks = []
    config_stub = Object.new
    config_stub.define_singleton_method(:to_prepare) do |&block|
      to_prepare_blocks << block
    end

    abstract_model = Class.new do
      def self.abstract_class?
        true
      end
    end
    concrete_model = Class.new do
      def self.abstract_class?
        false
      end
    end
    applied = []

    RecordingStudioFeatures::Engine.stub(:config, config_stub) do
      find_initializer("recording_studio_features.apply_model_extensions").block.call
    end

    ActiveRecord::Base.stub(:descendants, [abstract_model, concrete_model]) do
      RecordingStudioFeatures::Engine.stub(:apply_model_extensions, ->(model) { applied << model }) do
        to_prepare_blocks.first.call
      end
    end

    assert_equal [concrete_model], applied
  end

  def test_controller_extension_initializer_applies_all_controllers
    to_prepare_blocks = []
    config_stub = Object.new
    config_stub.define_singleton_method(:to_prepare) do |&block|
      to_prepare_blocks << block
    end

    first_controller = Class.new
    second_controller = Class.new
    applied = []

    RecordingStudioFeatures::Engine.stub(:config, config_stub) do
      find_initializer("recording_studio_features.apply_controller_extensions").block.call
    end

    ActionController::Base.stub(:descendants, [first_controller, second_controller]) do
      RecordingStudioFeatures::Engine.stub(:apply_controller_extensions, ->(controller) { applied << controller }) do
        to_prepare_blocks.first.call
      end
    end

    assert_equal [first_controller, second_controller], applied
  end

  def test_apply_model_extensions_adds_registered_methods_once
    model_class = Class.new do
      def self.name
        "ExampleRecord"
      end
    end

    RecordingStudioFeatures.configuration.hooks.extend_model(:ExampleRecord) do
      def template_extension_method
        :applied
      end
    end

    RecordingStudioFeatures::Engine.apply_model_extensions(model_class)
    RecordingStudioFeatures::Engine.apply_model_extensions(model_class)

    instance = model_class.new
    assert_equal :applied, instance.template_extension_method
  end

  def test_apply_controller_extensions_matches_demodulized_name
    controller_class = Class.new do
      def self.name
        "Admin::DashboardController"
      end
    end

    RecordingStudioFeatures.configuration.hooks.extend_controller(:DashboardController) do
      def template_controller_extension
        :applied
      end
    end

    RecordingStudioFeatures::Engine.apply_controller_extensions(controller_class)

    instance = controller_class.new
    assert_equal :applied, instance.template_controller_extension
  end

  def test_apply_model_extensions_skips_duplicate_extension_blocks
    target = Class.new do
      def self.name
        "GeneratedRecord"
      end
    end
    calls = 0
    extension = proc do
      calls += 1
      def generated_method
        :generated
      end
    end

    RecordingStudioFeatures.configuration.hooks.extend_model(:GeneratedRecord, &extension)
    RecordingStudioFeatures.configuration.hooks.extend_model(:GeneratedRecord, &extension)

    RecordingStudioFeatures::Engine.apply_model_extensions(target)
    RecordingStudioFeatures::Engine.apply_model_extensions(target)

    assert_equal :generated, target.new.generated_method
    assert_equal 1, calls
  end

  def test_apply_model_extensions_returns_without_target
    assert_nil RecordingStudioFeatures::Engine.apply_model_extensions(nil)
  end

  def test_extension_keys_include_namespaced_and_demodulized_controller_names
    namespaced = Class.new do
      def self.name
        "Admin::ReportsController"
      end
    end
    RecordingStudioFeatures.configuration.hooks.extend_controller(:"Admin::ReportsController") do
      def namespaced_extension
        :namespaced
      end
    end
    RecordingStudioFeatures.configuration.hooks.extend_controller(:ReportsController) do
      def demodulized_extension
        :demodulized
      end
    end

    RecordingStudioFeatures::Engine.apply_controller_extensions(namespaced)
    instance = namespaced.new

    assert_equal :namespaced, instance.namespaced_extension
    assert_equal :demodulized, instance.demodulized_extension
  end

  def test_extension_keys_for_plain_controller_name_apply_once
    plain = Class.new do
      def self.name
        "ReportsController"
      end
    end
    calls = 0
    extension = proc do
      calls += 1
      def reports_extension
        :applied
      end
    end

    RecordingStudioFeatures.configuration.hooks.extend_controller(:ReportsController, &extension)
    RecordingStudioFeatures::Engine.apply_controller_extensions(plain)

    assert_equal :applied, plain.new.reports_extension
    assert_equal 1, calls
  end

  private

  def find_initializer(name)
    RecordingStudioFeatures::Engine.initializers.find { |initializer| initializer.name == name }
  end
end
