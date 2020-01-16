module SupportInterface
  class TasksController < SupportInterfaceController
    def index; end

    def run
      case params.fetch(:task)
      when 'generate_test_applications'
        GenerateTestApplications.perform_async
        flash[:success] = 'Scheduled job to generate test applications - this might take a while!'
        redirect_to support_interface_tasks_path
      when 'create_vendor_providers'
        GenerateVendorProviders.call
        flash[:success] = 'Created test providers for vendors'
        redirect_to support_interface_tasks_path
      when 'sync_providers'
        SyncAllFromFind.perform_async
        flash[:success] = 'Scheduled provider sync'
        redirect_to support_interface_tasks_path
      else
        render_404
      end
    end
  end
end
