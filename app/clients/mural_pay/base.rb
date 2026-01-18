module MuralPay
  class Base
    BASE_URL = ENV.fetch("MURAL_PAY_BASE_URL", "https://api-staging.muralpay.com")

    def initialize(api_key: nil)
      @api_key = api_key || ENV.fetch("MURAL_PAY_API_KEY")
    end

    private

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |f|
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.adapter Faraday.default_adapter
      end
    end

    def get(path, params = {})
      response = connection.get(path, params) do |req|
        apply_headers(req)
      end
      handle_response(response)
    end

    def post(path, body = {})
      response = connection.post(path, body) do |req|
        apply_headers(req)
      end
      handle_response(response)
    end

    def put(path, body = {})
      response = connection.put(path, body) do |req|
        apply_headers(req)
      end
      handle_response(response)
    end

    def patch(path, body = {})
      response = connection.patch(path, body) do |req|
        apply_headers(req)
      end
      handle_response(response)
    end

    def delete(path)
      response = connection.delete(path) do |req|
        apply_headers(req)
      end
      handle_response(response)
    end

    def apply_headers(request)
      request.headers["Authorization"] = "Bearer #{@api_key}"
      request.headers["Content-Type"] = "application/json"
    end

    def handle_response(response)
      case response.status
      when 200..299
        response.body
      when 401
        raise AuthenticationError, "Invalid API key"
      when 404
        raise NotFoundError, "Resource not found"
      when 422
        raise ValidationError, response.body["message"] || "Validation failed"
      when 429
        raise RateLimitError, "Rate limit exceeded"
      else
        raise Error, response.body["message"] || "Request failed with status #{response.status}"
      end
    end

    class Error < StandardError; end
    class AuthenticationError < Error; end
    class NotFoundError < Error; end
    class ValidationError < Error; end
    class RateLimitError < Error; end
  end
end