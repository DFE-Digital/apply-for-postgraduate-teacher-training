module SupportInterface
  class ApplicationAPIRepresentationComponent < ViewComponent::Base
    include APIDocsHelper

    def initialize(application_choice:)
      @application_choice = application_choice
    end

  private

    def application_json
      VendorAPI::SingleApplicationPresenter.new(@application_choice).as_json
    end
  end
end
