class ChatChannel < ApplicationCable::Channel
  def subscribed
    logger.info "Subscribed..."
    stream_from "chat"
    # stream_from "some_channel"
  end

  def unsubscribed
    logger.info "Unsubscribed..."
    # Any cleanup needed when channel is unsubscribed
  end

  def send_message(payload)
    user_id = payload["user_id"]
    msg = payload["message"]
    user_name = payload["user_name"]
    ActionCable.server.broadcast "chat", {message: msg, user_id: user_id, user_name: user_name}
  end
end
