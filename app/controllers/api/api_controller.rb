class Api::ApiController < ActionController::Base

  def cors_preflight
    headers["Access-Control-Allow-Origin"] = "http://localhost:8888"
    headers["Access-Control-Allow-Methods"] = "POST"
    headers["Access-Control-Allow-Headers"] = "Origin, X-Requested-With, Content-Type, Accept"
    render text: "", status: :ok
  end

  def allow_cors
    headers["Access-Control-Allow-Origin"] = "http://localhost:8888"
    headers["Access-Control-Allow-Headers"] = "Origin, X-Requested-With, Content-Type, Accept"
  end
end
