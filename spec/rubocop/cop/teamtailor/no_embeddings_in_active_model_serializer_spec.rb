# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Teamtailor::NoEmbeddingsInActiveModelSerializer, :config do
  let(:config) { RuboCop::Config.new }

  context "when in a serializer" do
    it "registers an offense when using `has_many` with embed" do
      expect_offense(<<~RUBY)
        class FooSerializer < ActiveModel::Serializer
          has_many :locations, embed: :ids
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Teamtailor/NoEmbeddingsInActiveModelSerializer: No embedding of records
        end
      RUBY
    end

    it "registers an offense when using `has_many` with embed_in_root" do
      expect_offense(<<~RUBY)
        class FooSerializer < ActiveModel::Serializer
          has_many :locations, embed_in_root: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Teamtailor/NoEmbeddingsInActiveModelSerializer: No embedding of records
        end
      RUBY
    end

    it "registers an offense when using `has_one` with embed_in_root" do
      expect_offense(<<~RUBY)
        class FooSerializer < ActiveModel::Serializer
          has_one :location, embed_in_root: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Teamtailor/NoEmbeddingsInActiveModelSerializer: No embedding of records
        end
      RUBY
    end

    it "registers an offense when using `has_one` with embed" do
      expect_offense(<<~RUBY)
        class FooSerializer < ActiveModel::Serializer
          has_one :location, embed: :ids
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Teamtailor/NoEmbeddingsInActiveModelSerializer: No embedding of records
        end
      RUBY
    end

    it "registers offenses for all `has_many`" do
      expect_offense(<<~RUBY)
        class FooSerializer < ActiveModel::Serializer
          has_many :locations, embed: :ids
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Teamtailor/NoEmbeddingsInActiveModelSerializer: No embedding of records
          has_many :users, embed: :ids
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Teamtailor/NoEmbeddingsInActiveModelSerializer: No embedding of records
        end
      RUBY
    end

    it "registers offenses for both `has_many` and `has_one` with embed" do
      expect_offense(<<~RUBY)
        class FooSerializer < ActiveModel::Serializer
          has_many :locations, embed: :ids
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Teamtailor/NoEmbeddingsInActiveModelSerializer: No embedding of records
          has_one :user, embed: :id
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Teamtailor/NoEmbeddingsInActiveModelSerializer: No embedding of records
        end
      RUBY
    end

    it "does not register an offence when no has_one/has_many" do
      expect_no_offenses(<<~RUBY)
        class FooSerializer < ActiveModel::Serializer
          attributes :location_ids
        end
      RUBY
    end

    it "does not register an offence when no has_one/has_many without embedding" do
      expect_no_offenses(<<~RUBY)
        class FooSerializer < OjSerializer
          has_many :locations, serializer: LocationSerializer
          has_one :candidate, serializer: CandidateSerializer
        end
      RUBY
    end
  end

  context "when not in a serializer" do
    it "does not register an offense when using has_many" do
      expect_no_offenses(<<~RUBY)
        class Foo
          has_many :locations
          has_one :user
        end
      RUBY
    end
  end
end
