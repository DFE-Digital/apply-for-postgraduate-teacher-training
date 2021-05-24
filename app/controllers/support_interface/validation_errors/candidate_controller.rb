module SupportInterface
  module ValidationErrors
    class CandidateController < SupportInterface::ValidationErrorsController
      def index
        @grouped_counts = ValidationError.group(:form_object).order('count_all DESC').count
        @list_of_distinct_errors_with_counts = ValidationError.list_of_distinct_errors_with_count
      end

      def search
        @validation_errors = ValidationError
          .search(params)
          .order('created_at DESC')
          .page(params[:page] || 1)
      end

      def summary
        sort_param = params.permit(:sortby)[:sortby]

        @validation_error_summary = ::ValidationErrorSummaryQuery.new(:apply, sort_param).call
      end
    end
  end
end
