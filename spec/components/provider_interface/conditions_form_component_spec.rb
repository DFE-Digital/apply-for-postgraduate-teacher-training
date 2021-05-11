require 'rails_helper'

RSpec.describe ProviderInterface::ConditionsFormComponent do
  let(:application_choice) { build_stubbed(:submitted_application_choice) }
  let(:form_object_class) do
    Class.new do
      include ActiveModel::Model
      attr_accessor :standard_conditions, :condition_models
    end
  end

  let(:further_conditions) { [] }
  let(:condition_models) do
    further_conditions.map.with_index do |condition, index|
      OpenStruct.new(id: index, text: condition)
    end
  end

  let(:form_object) { FormObjectClass.new(condition_models: condition_models) }

  let(:component) do
    described_class.new(
      application_choice: application_choice,
      form_object: form_object,
      form_method: :post,
      form_heading: 'Title',
    )
  end
  let(:render) { render_inline(component) }

  before do
    stub_const('FormObjectClass', form_object_class)
  end

  context 'When the form object has no further conditions set' do
    it 'renders no text boxes' do
      expect(render.css('textarea')).to be_empty
    end

    it 'renders the add another button' do
      expect(render.css('.app-add-another__add-button').text.squish).to eq('Add another condition')
    end
  end

  context 'When the form object has further conditions set' do
    let(:further_conditions) { ['Do a backflip and send a video', 'Be uncool'] }

    it 'renders the conditions in the text area' do
      expect(render.css('textarea').first.text).to include('Do a backflip and send a video')
      expect(render.css('textarea').last.text).to include('Be uncool')
    end

    it 'renders the correct numbering for the labels' do
      expect(render.css('.app-add-another__item > .govuk-form-group > .govuk-label').map(&:text)).to contain_exactly('Condition 1', 'Condition 2')
    end

    it 'renders the add another button' do
      expect(render.css('.app-add-another__add-button').text.squish).to eq('Add another condition')
    end

    it 'renders the remove condition links' do
      expect(render.css('.app-add-another__remove-button').map(&:text).map(&:squish)).to contain_exactly('Remove condition 1', 'Remove condition 2')
    end
  end

  context 'when the form object has 20 conditions set' do
    let(:further_conditions) { Array.new(20, 'condition text') }

    it 'does not render the add another button' do
      expect(render.css('.app-add-another__add-button')).to be_empty
    end
  end
end
