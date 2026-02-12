# frozen_string_literal: true

require "spec_helper"
require "rubocop"
require "rubocop/rspec/cop_helper"

RSpec.describe RuboCop::Cop::Teamtailor::AlphabeticalSerializerAttributes do
  include CopHelper

  let(:config) { RuboCop::Config.new }
  let(:cop_class) { described_class }
  let(:cop) { described_class.new(config) }

  it "registers an offense and autocorrects arguments" do
    source = <<~RUBY
      class UserSerializer
        attributes :last_name,
                   :first_name,
                   foo: :bar,
                   baz: :qux
      end
    RUBY

    offenses = inspect_source(source)

    expect(offenses.size).to eq(1)
    expect(offenses.first.message).to eq("#{described_class.cop_name}: #{described_class::MSG}")

    corrected = autocorrect_source(source)

    expect(corrected).to eq(<<~RUBY)
      class UserSerializer
        attributes :first_name,
                   :last_name,
                   baz: :qux,
                   foo: :bar
      end
    RUBY
  end

  it "autocorrects multi-line arguments with aligned indentation" do
    source = <<~RUBY
      class UserSerializer
        attributes :last_name,
                   :first_name,
                   foo: :bar,
                   baz: :qux
      end
    RUBY

    corrected = autocorrect_source(source)

    expect(corrected).to eq(<<~RUBY)
      class UserSerializer
        attributes :first_name,
                   :last_name,
                   baz: :qux,
                   foo: :bar
      end
    RUBY
  end

  it "registers an offense and autocorrects serializer_attributes calls" do
    source = <<~RUBY
      class UserSerializer
        serializer_attributes :last_name,
                              :first_name,
                              foo: :bar,
                              baz: :qux
      end
    RUBY

    corrected = autocorrect_source(source)

    expect(corrected).to eq(<<~RUBY)
      class UserSerializer
        serializer_attributes :first_name,
                              :last_name,
                              baz: :qux,
                              foo: :bar
      end
    RUBY
  end

  it "autocorrects symbol-only arguments" do
    source = <<~RUBY
      class UserSerializer
        attributes :last_name,
                   :first_name
      end
    RUBY

    corrected = autocorrect_source(source)

    expect(corrected).to eq(<<~RUBY)
      class UserSerializer
        attributes :first_name,
                   :last_name
      end
    RUBY
  end

  it "keeps splat arguments at the start while sorting the rest" do
    source = <<~RUBY
      class UserSerializer
        attributes *BASE_ATTRIBUTES,
                   :last_name,
                   :first_name,
                   foo: :bar,
                   baz: :qux
      end
    RUBY

    corrected = autocorrect_source(source)

    expect(corrected).to eq(<<~RUBY)
      class UserSerializer
        attributes *BASE_ATTRIBUTES,
                   :first_name,
                   :last_name,
                   baz: :qux,
                   foo: :bar
      end
    RUBY
  end

  it "moves splat arguments to the start when they are out of order" do
    source = <<~RUBY
      class UserSerializer
        attributes :last_name,
                   *BASE_ATTRIBUTES,
                   :first_name,
                   foo: :bar,
                   baz: :qux
      end
    RUBY

    corrected = autocorrect_source(source)

    expect(corrected).to eq(<<~RUBY)
      class UserSerializer
        attributes *BASE_ATTRIBUTES,
                   :first_name,
                   :last_name,
                   baz: :qux,
                   foo: :bar
      end
    RUBY
  end

  it "moves non-symbol arguments ahead of sorted symbols and hashes" do
    source = <<~RUBY
      class UserSerializer
        attributes :last_name,
                   base_attributes,
                   :first_name,
                   foo: :bar
      end
    RUBY

    corrected = autocorrect_source(source)

    expect(corrected).to eq(<<~RUBY)
      class UserSerializer
        attributes base_attributes,
                   :first_name,
                   :last_name,
                   foo: :bar
      end
    RUBY
  end

  it "handles keyword splats mixed with hash pairs" do
    source = <<~RUBY
      class UserSerializer
        attributes :last_name,
                   :first_name,
                   **EXTRA_ATTRIBUTES,
                   foo: :bar,
                   baz: :qux
      end
    RUBY

    corrected = autocorrect_source(source)

    expect(corrected).to eq(<<~RUBY)
      class UserSerializer
        attributes :first_name,
                   :last_name,
                   **EXTRA_ATTRIBUTES,
                   baz: :qux,
                   foo: :bar
      end
    RUBY
  end

  it "preserves non-symbol arguments in multi-line calls" do
    source = <<~RUBY
      class UserSerializer
        attributes base_attributes,
                   :last_name,
                   :first_name,
                   foo: :bar,
                   baz: :qux
      end
    RUBY

    corrected = autocorrect_source(source)

    expect(corrected).to eq(<<~RUBY)
      class UserSerializer
        attributes base_attributes,
                   :first_name,
                   :last_name,
                   baz: :qux,
                   foo: :bar
      end
    RUBY
  end

  it "sorts hash keys that are not symbols" do
    source = <<~RUBY
      class UserSerializer
        attributes :first_name,
                   "z" => :z,
                   "a" => :a
      end
    RUBY

    corrected = autocorrect_source(source)

    expect(corrected).to eq(<<~RUBY)
      class UserSerializer
        attributes :first_name,
                   "a" => :a,
                   "z" => :z
      end
    RUBY
  end

  it "does not register offenses for sorted hash literal arguments" do
    source = <<~RUBY
      class UserSerializer
        attributes :first_name,
                   { a: :a, b: :b }
      end
    RUBY

    offenses = inspect_source(source)

    expect(offenses).to be_empty
  end

  it "sorts explicit pair nodes when provided" do
    pair_nodes = RuboCop::AST::ProcessedSource.new("{ b: :b, a: :a }", RUBY_VERSION.to_f).ast.children

    sorted = cop.send(:sort_arguments, pair_nodes)

    expect(sorted.map(&:source)).to eq(["a: :a", "b: :b"])
  end
end
