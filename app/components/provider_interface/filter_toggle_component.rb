module ProviderInterface
  class FilterToggleComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :page_state
    delegate :filters, to: :page_state

    def initialize(page_state:)
      @page_state = page_state
    end

    def toggle_button_text
      toggle_control ? 'Hide filter' : 'Show filter'
    end

    def toggle_params
      toggle = { filter_visible: [toggle_control] }
      @page_state.applied_filters.merge(toggle)
    end

  private

    def toggle_control
      @page_state.filter_visible?
    end
  end
end
