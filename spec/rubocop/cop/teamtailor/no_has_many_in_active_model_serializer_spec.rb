# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Teamtailor::NoHasManyInActiveModelSerializer, :config do
  let(:config) { RuboCop::Config.new }

  context "when in a serializer" do
    it "registers an offense when using `has_many`" do
      expect_offense(<<~RUBY)
        class FooSerializer < ActiveModel::Serializer
          has_many :locations, embed: :ids
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Teamtailor/NoHasManyInActiveModelSerializer: No embedding of records
        end
      RUBY
    end

    it "registers an offense for all `has_many`" do
      expect_offense(<<~RUBY)
        class FooSerializer < ActiveModel::Serializer
          has_many :locations, embed: :ids
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Teamtailor/NoHasManyInActiveModelSerializer: No embedding of records
          has_many :users, embed: :ids
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Teamtailor/NoHasManyInActiveModelSerializer: No embedding of records
        end
      RUBY
    end

    it "does not register an offense `has_one`" do
      expect_no_offenses(<<~RUBY)
        class FooSerializer < ActiveModel::Serializer
          attributes :location_ids
        end
      RUBY
    end
  end

  context "when not in a serializer" do
    it "does not register an offense when using has_many" do
      expect_no_offenses(<<~RUBY)
        class Foo
          has_many :locations
        end
      RUBY
    end
  end
end
