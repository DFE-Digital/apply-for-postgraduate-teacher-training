module CandidateInterface
  class Gcse::YearController < Gcse::BaseController
    def edit
      @year_form = CandidateInterface::GcseYearForm.build_from_qualification(current_qualification)
    end

    def update
      @year_form = CandidateInterface::GcseYearForm.new(year_params)

      if @year_form.save(current_qualification)
        redirect_to candidate_interface_gcse_review_path
      else
        track_validation_error(@year_form)

        render :edit
      end
    end

  private

    def year_params
      strip_whitespace params
        .require(:candidate_interface_gcse_year_form)
        .permit(:award_year)
        .merge!(qualification_type: current_qualification.qualification_type)
    end
  end
end
