module CandidateInterface
  class Reference::RefereeTypeForm
    include ActiveModel::Model

    attr_accessor :referee_type

    validates :referee_type, presence: true, inclusion: { in: ApplicationReference.referee_types.values }

    def self.build_from_reference(reference)
      new(referee_type: reference.referee_type)
    end

    def save(reference)
      return false unless valid?

      reference.update!(referee_type: referee_type)
    end
  end
end
