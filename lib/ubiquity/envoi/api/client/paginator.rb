class Ubiquity::Envoi::API::Client::Paginator

  attr_accessor :api_client, :logger

  def initialize(api_client, options = { })
    @api_client = api_client
    initialize_logger(options)
  end

  def initialize_logger(args = {})
    @logger   = args[:logger] ||= Logger.new(args[:log_to] || STDOUT)
    log_level = args[:log_level]
    if log_level
      _logger = @logger.dup
      _logger.level = log_level
      @logger = _logger
    end
    @logger
  end

  def current_page
    @current_page ||= last_response['page']
  end

  def http_client
    api_client.http_client
  end

  def include_remaining_pages
    # response = api_client.response.dup
    @first_page = current_page
    _results = last_results
    _results.concat(remaining_pages_get)
    _per_page = _results.length
    last_response.merge({ 'page' => @first_page, 'perPage' => _per_page, 'results' => _results })
  end

  def last_response
    @last_response ||= api_client.http_client.response_parsed
  end

  def last_results
    @last_results ||= last_response['results']
  end

  def next_page?
    current_page < total_pages
  end

  def next_page_get(_next_page_number = nil)
    _next_page_number ||= next_page_number
    page_get(_next_page_number)
  end

  def next_page_number
    @next_page_number ||= current_page + 1
  end

  def page_size
    @page_size ||= last_response['perPage']
  end

  def page_get(page_number)
    logger.debug { "Getting Page #{page_number} of #{total_pages}" }
    new_request = request.class.new(request_args_out.merge('_page' => page_number), request_options_out)
    _response = new_request.execute
    process_response
  end

  def pages_get(pages, options = { })
    consolidate = options.fetch(:consolidate, true)
    pages = pages.to_a if pages.respond_to?(:to_a)
    pages_out = pages.map { |v| page_get(v) }
    pages_out.flatten! if consolidate
    pages_out
  end

  def paginated?
    @paginated = !!total_results
  end

  def process_request
    @current_page = nil
    @total_results = nil
    @has_next_page = nill
  end

  def process_response
    @current_page = nil
    @last_response = nil
    @next_page_number = nil
    @page_size = nil
    @total_pages = nil
    @total_results = nil
    @paginated = !!total_results

    @last_results = last_response['results']
  end

  def request
    api_client.request
  end

  def request_args_out
    @request_args_out ||= request.initial_arguments.dup
  end

  def request_options_out
    @request_options_out ||= { :client => api_client }.merge request.initial_options.dup
  end

  def total_pages
    @total_pages ||= begin
      logger.debug { "Page Size: #{page_size}" }
      logger.debug { "Total Results: #{total_results}" }

      div = total_results / page_size
      mod = total_results % page_size
      remainder = div == mod ? 0 : 1
      _total_pages = div + remainder
      logger.debug { "Total Pages: #{_total_pages}" }
      _total_pages
    end
  end

  def total_results
    @total_results ||= last_response['total']
  end

  def remaining_pages_get
    return [ ] unless paginated? && next_page?
    remaining_results = [ ]

    loop do
      response = next_page_get
      remaining_results.concat(response)

      break unless next_page?
    end
    remaining_results
  end

end
