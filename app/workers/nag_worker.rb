class NagWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}."
  end
  
  def perform(nag_id)
    @nag = Nag.find(nag_id)
    Message.send_nag(@nag)
  end
end
