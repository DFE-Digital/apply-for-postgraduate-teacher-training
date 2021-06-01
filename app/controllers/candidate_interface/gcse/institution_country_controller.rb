module CandidateInterface
  class Gcse::InstitutionCountryController < Gcse::BaseController
    def new
      @institution_country = GcseInstitutionCountryForm.build_from_qualification(current_qualification)
    end

    def create
      @institution_country = GcseInstitutionCountryForm.new(institution_country_params)

      if @institution_country.save(current_qualification)
        redirect_to candidate_interface_gcse_details_edit_enic_path
      else
        track_validation_error(@institution_country)
        render :new
      end
    end

    def edit
      @institution_country = GcseInstitutionCountryForm.build_from_qualification(current_qualification)
    end

    def update
      @institution_country = GcseInstitutionCountryForm.new(institution_country_params)

      if @institution_country.save(current_qualification)
        redirect_to candidate_interface_gcse_review_path
      else
        track_validation_error(@institution_country)
        render :edit
      end
    end

  private

    def institution_country_params
      strip_whitespace params
        .require(:candidate_interface_gcse_institution_country_form)
        .permit(:institution_country)
    end
  end
end
