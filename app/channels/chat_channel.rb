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
    msg = payload["message"]
    ActionCable.server.broadcast "chat", {message: msg}
  end
end
