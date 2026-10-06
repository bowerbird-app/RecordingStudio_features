# frozen_string_literal: true

require "test_helper"
require "generators/recording_studio_features/migrations/migrations_generator"

class MigrationsGeneratorTest < Minitest::Test
  def test_next_migration_number_advances_within_the_same_second
    generator = RecordingStudioFeatures::Generators::MigrationsGenerator.new([], {}, destination_root: "/tmp")

    first = generator.send(:next_migration_number)
    second = generator.send(:next_migration_number)

    refute_equal first, second
    assert_operator second.to_i, :>, first.to_i
  end
end
