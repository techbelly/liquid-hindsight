# frozen_string_literal: true

module Liquid
  # Context keeps the variable stack and resolves variables, as well as keywords
  #
  #   context['variable'] = 'testing'
  #   context['variable'] #=> 'testing'
  #   context['true']     #=> true
  #   context['10.2232']  #=> 10.2232
  #
  #   context.stack do
  #      context['bob'] = 'bobsen'
  #   end
  #
  #   context['bob']  #=> nil  class Context
  class Context
    attr_reader :scopes, :errors, :registers, :environments, :resource_limits, :static_registers, :static_environments
    attr_accessor :exception_renderer, :template_name, :partial, :global_filter, :strict_variables, :strict_filters, :environment

    # rubocop:disable Metrics/ParameterLists

    # rubocop:enable Metrics/ParameterLists

    protected

    attr_writer :base_scope_depth, :warnings, :errors, :strainer, :filters, :disabled_tags

    private

    attr_reader :base_scope_depth
  end # Context
end # Liquid
