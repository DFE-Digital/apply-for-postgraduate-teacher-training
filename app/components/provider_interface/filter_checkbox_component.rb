module ProviderInterface
  class FilterCheckboxComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :name, :text

    def initialize(name:, text:)
      @name = name
      @text = text
    end
  end
end
