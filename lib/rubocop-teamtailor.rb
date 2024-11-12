# frozen_string_literal: true

require "rubocop"

require_relative "rubocop/teamtailor"
require_relative "rubocop/teamtailor/version"
require_relative "rubocop/teamtailor/inject"

RuboCop::Teamtailor::Inject.defaults!

require_relative "rubocop/cop/teamtailor_cops"
