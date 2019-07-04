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
    data = payload["message"]
    user_id = data["userId"]
    msg = data["message"]
    ActionCable.server.broadcast "chat", {message: msg, user_id: user_id}
  end
end
