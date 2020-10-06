class SectionMissingBannerComponent < ViewComponent::Base
  validates :section, :section_path, presence: true

  def initialize(
    section:,
    section_path:,
    text: t("review_application.#{section}.incomplete"),
    link_text: t("review_application.#{section}.complete_section"),
    error: false
  )
    @section = section
    @section_path = section_path
    @text = text
    @error = error
    @link_text = link_text
  end

  attr_reader :section, :section_path, :text, :link_text
end
