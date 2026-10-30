# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "tmpdir"
require "generators/recording_studio_features/migrations/migrations_generator"

class MigrationsGeneratorTest < Minitest::Test
  def test_copy_migrations_advances_timestamps_within_the_same_second
    Dir.mktmpdir do |dir|
      source_root = File.join(dir, "source")
      destination_root = File.join(dir, "app")
      migrations_dir = File.join(source_root, "db", "migrate")
      FileUtils.mkdir_p(migrations_dir)
      FileUtils.mkdir_p(File.join(destination_root, "db/migrate"))
      File.write(File.join(migrations_dir, "20261006000001_create_recording_studio_features.rb"), "# first\n")
      File.write(File.join(migrations_dir, "20261006000002_add_feature_index.rb"), "# second\n")

      generator = RecordingStudioFeatures::Generators::MigrationsGenerator.new(
        [],
        { skip_existing: false },
        destination_root: destination_root
      )
      copied = []
      frozen_time = Time.utc(2026, 10, 30, 12, 0, 0)

      generator.class.stub(:source_root, source_root) do
        Time.stub(:now, frozen_time) do
          generator.stub(:copy_file, ->(_source, destination) { copied << destination }) do
            generator.stub(:say, nil) { generator.copy_migrations }
          end
        end
      end

      timestamps = copied.map { |path| File.basename(path)[/\A(\d+)_/, 1] }

      assert_equal 2, timestamps.size
      refute_equal timestamps.first, timestamps.last
      assert_operator timestamps.last.to_i, :>, timestamps.first.to_i
    end
  end
end
