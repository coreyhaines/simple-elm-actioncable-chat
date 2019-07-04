module ApplicationCable
  class Connection < ActionCable::Connection::Base
    def connect
      logger.info "Connected..."
    end
  end
end
