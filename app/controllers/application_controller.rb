require 'securerandom'
class ApplicationController < ActionController::Base
  before_action :set_chat_user_id


  def set_chat_user_id
    @chat_user_id = if cookies[:chat_user_id]
                cookies[:chat_user_id]
              else
                cookies[:chat_user_id] = SecureRandom.uuid
              end
  end
end
