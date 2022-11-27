class Api::V1::UsersController < ApplicationController
  # include SocialClientService
  skip_before_action :current_user, only: :create

  def index
    @users = User.all
  end

  def create
    user = User.new(user_params)
    if avator_image = avator_image_params
      user.avator_image.attach(io: avator_image, filename: "#{Time.now.to_i}_#{user.id}.jpg" , content_type: "image/jpg" )
    end

    if user.save!
      @user = user
      @avator_image_size = avator_image ? avator_image.length : 0
      return
    else
      response_internal_server_error
    end
  end

  def create_with_social_accounts
    onetime_token = params[:onetime_token]
    exchange_json = OneTimeToken.find_valid_token(onetime_token)

    user = SocialClientService.create_accounts_with_google_profile!(exchange_json['token'])
    @user = user
  end

  def avator_image_download
    user = User.first
    send_data user.avator_image.download, type: "image/jpg", disposition: 'inline'
  end

  private
    def user_params
      user = params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def avator_image_params
      avator_image = convert_base64_to_image(params[:user][:avator_image])
    end

    def convert_base64_to_image(base64_image)
      if base64_image.nil?
        return nil
      end
      decoded_image = Base64.decode64(base64_image)

      file = Tempfile.new
      file.binmode
      file.write(decoded_image)
      file.rewind
      file
    end
end
