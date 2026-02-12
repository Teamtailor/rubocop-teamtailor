# frozen_string_literal: true

module RuboCop
  module Cop
    module Teamtailor
      class AlphabeticalSerializerAttributes < Base
        extend AutoCorrector

        MSG = "Serializer attributes should be in alphabetical order (symbols first, then hashes)"
        RESTRICT_ON_SEND = %i[attributes serializer_attributes].freeze

        def on_send(node)
          return unless node.arguments.any?
          return unless in_serializer_class?(node)

          args = node.arguments
          sorted_args = sort_arguments(args)
          return if args_match?(args, sorted_args)

          add_offense(node) do |corrector|
            corrector.replace(arguments_range(node), format_arguments(sorted_args, node))
          end
        end

        private

        def in_serializer_class?(node)
          node.each_ancestor(:class).any? do |class_node|
            class_node.defined_module_name&.end_with?("Serializer")
          end
        end

        def sort_arguments(args)
          symbols = []
          splats = []
          others = []
          hash_items = []

          args.each do |arg|
            if arg.splat_type?
              splats << arg
            elsif arg.sym_type?
              symbols << arg
            elsif arg.pair_type?
              hash_items << arg
            elsif arg.hash_type?
              arg.children.each { |child| hash_items << child }
            else
              others << arg
            end
          end

          sorted_symbols = symbols.sort_by { |symbol| symbol.value.to_s }
          sorted_pairs = hash_items.select(&:pair_type?).sort_by { |pair| extract_hash_key(pair) }
          sorted_hash_items = hash_items.map do |item|
            item.pair_type? ? sorted_pairs.shift : item
          end

          splats + others + sorted_symbols + sorted_hash_items
        end

        def extract_hash_key(pair_node)
          key = pair_node.key
          key.sym_type? ? key.value.to_s : key.source
        end

        def args_match?(original, sorted)
          original_flat = flatten_args(original)
          original_flat.map(&:source) == sorted.map(&:source)
        end

        def flatten_args(args)
          args.flat_map do |arg|
            if arg.hash_type?
              arg.children
            else
              arg
            end
          end
        end

        def arguments_range(node)
          first_arg = node.arguments.first
          last_arg = node.arguments.last
          first_arg.source_range.join(last_arg.source_range)
        end

        def format_arguments(sorted_args, node)
          return sorted_args.map(&:source).join(", ") if single_line_call?(node)

          indent = argument_indent(node)
          all_args = sorted_args.dup
          first = all_args.shift

          lines = [first.source]
          all_args.each { |arg| lines << "#{indent}#{arg.source}" }

          lines.join(",\n")
        end

        def single_line_call?(node)
          node.source_range.first_line == node.source_range.last_line
        end

        def argument_indent(node)
          first_arg = node.arguments.first
          " " * first_arg.source_range.column
        end
      end
    end
  end
end
