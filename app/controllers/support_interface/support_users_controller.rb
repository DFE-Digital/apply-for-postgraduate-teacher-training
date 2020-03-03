module SupportInterface
  class SupportUsersController < SupportInterfaceController
    def index
      @support_users = SupportUser.kept
    end

    def new
      @support_user = SupportUser.new
    end

    def create
      @support_user = SupportUser.new(support_user_params)

      if @support_user.save
        flash[:success] = 'Support user created'
        redirect_to support_interface_support_users_path
      else
        render :new
      end
    end

    def confirm_destroy
      @support_user = SupportUser.find(params[:id])
    end

    def destroy
      SupportUser.find(params[:id]).discard
      flash[:success] = 'Support user removed'
      redirect_to support_interface_support_users_path
    end

  private

    def support_user_params
      params.require(:support_user).permit(:email_address, :dfe_sign_in_uid)
    end
  end
end
