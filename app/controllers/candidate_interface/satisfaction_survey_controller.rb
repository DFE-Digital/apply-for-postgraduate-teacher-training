module CandidateInterface
  class SatisfactionSurveyController < CandidateInterfaceController
    def recommendation
      @survey = SatisfactionSurveyForm.new
    end

    def submit_recommendation
      post_route_action(candidate_interface_satisfaction_survey_complexity_path, :recommendation)
    end

    def complexity
      @survey = SatisfactionSurveyForm.new
    end

    def submit_complexity
      post_route_action(candidate_interface_satisfaction_survey_ease_of_use_path, :complexity)
    end

    def ease_of_use
      @survey = SatisfactionSurveyForm.new
    end

    def submit_ease_of_use
      post_route_action(candidate_interface_satisfaction_survey_help_needed_path, :ease_of_use)
    end

    def help_needed
      @survey = SatisfactionSurveyForm.new
    end


  private

    def survey_params
      params.require(:candidate_interface_satisfaction_survey_form)
        .permit(:answer).merge!(question: get_question_asked_from_params)
    end

    def get_question_asked_from_params
      # removes 'submit_' from the controller action
      page_title = params['action'].split('_').drop(1).join('_')
      t("page_titles.#{page_title}")
    end

    def post_route_action(next_path, current_view)
      @survey = SatisfactionSurveyForm.new(survey_params)

      if @survey.save(current_application)
        redirect_to next_path
      else
        @survey = SatisfactionSurveyForm.new

        render current_view
      end
    end
  end
end
