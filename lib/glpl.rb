require 'json'
require 'net/http'

METHOD_CLASSES    = {get: Net::HTTP::Get, post: Net::HTTP::Post}

# --- FUNCTIONS

class GLPL
  ##
  # Creates a new GLPL instance with the provided Gitlab's Private Token.
  #
  # Params:
  # +private_token+:: +String+ Gitlab's Private Token to be used when making requests to Gitlab's API.
  def initialize(private_token)
    @private_token = private_token
    @api_url = "https://gitlab.com/api/v4/projects"
  end

  # Prints the pipelines status for a given project.
  # Params:
  # +project_id+:: +String+ which contains the Gitlab's project id.
  def pipelines(project_id)
    request("/#{project_id}/pipelines", :get).map { |data| GLPL::Pipeline.new(data) }
  end

  # Makes an HTTP Requests to Gitlab's API and returns the response as JSON.
  # Params:
  # +endpoint+:: +String+ which represents the API's endpoint to be contacted.
  # +method+:: +Symbol+ of the HTTP method, either :get or :post.
  def request(endpoint, method)
    uri     = URI("#{@api_url}#{endpoint}")

    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      request                   = METHOD_CLASSES[method].new(uri)
      request["PRIVATE-TOKEN"]  = @private_token
      response                  = http.request(request)

      return JSON.parse(response.body)
    end
  end

  private :request
end

require 'glpl/pipeline'
