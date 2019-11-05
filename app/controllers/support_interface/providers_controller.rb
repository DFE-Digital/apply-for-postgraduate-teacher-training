module SupportInterface
  class ProvidersController < SupportInterfaceController
    def index
      @providers = Provider.all
    end

    def sync
      SyncProvidersFromFind.call
      redirect_to action: 'index'
    end
  end
end
