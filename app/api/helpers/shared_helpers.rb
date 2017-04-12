# Reusable helpers used in endpoints
module SharedHelpers
  extend Grape::API::Helpers

  params :envelope_id do
    requires :envelope_id, type: String, desc: 'Unique envelope identifier'
  end

  params :envelope_community do
    optional :envelope_community,
             values: -> { EnvelopeCommunity.pluck(:name) }
  end

  # duplicate of `:envelope_community` with a different name
  # in order to identify a clash between the url parameter and the body
  # parameter.
  # This should be consolidated e.g. by changing the parameter for the
  # /envelopes endpoint
  params :community_name do
    optional :community_name, values: -> { EnvelopeCommunity.pluck(:name) }
  end

  params :pagination do
    optional :page, type: Integer, default: 1, desc: 'Page number'
    optional :per_page, type: Integer, default: 10, desc: 'Items per page'
  end

  params :update_if_exists do
    optional :update_if_exists,
             type: Grape::API::Boolean,
             desc: 'Whether to update the envelope if it already exists',
             documentation: { param_type: 'query' }
  end

  params :skip_validation do
    optional :skip_validation,
             type: Grape::API::Boolean,
             desc: 'Whether to skip validations if the community allows',
             documentation: { param_type: 'query' }
  end

  def skip_validation?
    @skip_validation ||= params.delete(:skip_validation)
  end

  def update_if_exists?
    @update_if_exists ||= params.delete(:update_if_exists)
  end

  # Raise an API error.
  #
  # Params:
  #     - errs:    [Array|Hash]   error messages
  #     - schemas: [Array|String] one or more schema_names used for validation
  #     - status:  [Symbol|Int]   status code (default: unprocessable_entity)
  #
  # Response:
  #    {
  #       "errors": [ ... ],       // json formated err messages
  #       "json_schema": [ ... ],  // urls for the json_schemas
  #    }
  def json_error!(errs, schemas = nil, status = :unprocessable_entity)
    schema_names = Array(schemas) << :json_ld
    schema_urls = schema_names.compact.map { |name| url(:api, :schemas, name) }
    resp = { errors: errs }
    resp[:json_schema] = schema_urls if schema_urls.any?
    error! resp, status
  end

  def log_backtrace(e)
    MR.logger.error("\n#{e.backtrace.join("\n")}\n")
  end

  # URL builder
  #
  # Params:
  #   - path: [*String] splat list of string.
  #
  # Return: joined url
  #
  # Example:
  #    uri(:api, :bla, :something) # => 'http://<hostname>/api/bla/something'
  #
  def url(*path)
    ["#{request.scheme}://#{request.host_with_port}", *path].join('/')
  end

  # Set envelope_community to always be 'underscored' if present.
  # i.e: "Learning-registry" => "learning_registry"
  def normalize_envelope_community
    if params[:envelope_community].present?
      params[:envelope_community] = community
    end
  end

  # Get the community name from the params
  # Return: [String] community name
  def community
    params[:envelope_community].try(:underscore)
  end

  def test_response
    {}
  end
end