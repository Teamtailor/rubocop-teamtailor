# frozen_string_literal: true

module RuboCop
  module Cop
    module Teamtailor
      class NoEmbeddingsInActiveModelSerializer < Base
        MSG = "No embedding of records"

        def_node_matcher :no_has_many?, <<~PATTERN
          (send nil? {:has_many | :has_one} ...)
        PATTERN

        def on_class(class_node)
          return unless class_node.defined_module_name.end_with?("Serializer")
          check_children(class_node)
        end

        private

        def check_children(node)
          if no_has_many?(node)
            add_offense(node)
          end

          if node.respond_to?(:children)
            node.children.each { |child| check_children(child) }
          end
        end
      end
    end
  end
end
