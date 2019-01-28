namespace :OH do
  desc 'Fix broken links failed with "301: Net::HTTPMovedPermanently" error'

  task fix_broken_links_with_url_redirection: :environment do
    @max_limit = 10
    @valid_response_codes = %w[200 301 308]
    @log = Logger.new('log/fixed_link_with_url_redirection.log')

    BrokenLink.where(error: ['301: Net::HTTPMovedPermanently', '308: Net::HTTPRedirection']).each do |broken_link|
      @link = broken_link.link
      @log.info("#{@link.id}, #{@link.url}")
      code, new_url = fetch_response(@link.url)
      broken_link.destroy && next if code == '200'
      handle_url_redirection(new_url)
    end
  end

  def fetch_response(url)
    uri = URI(url)
    request = Net::HTTP::Head.new(uri.request_uri)
    response = http_object(uri).request(request)
    return unless response && @valid_response_codes.include?(response.code)
    [response.code, response['location']]
  rescue
    false
  end

  def http_object(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 30
    http.open_timeout = 30
    http.use_ssl = (uri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == 'https'
    http
  end

  def handle_url_redirection(url, limit = 1)
    return if url.blank? || @link.url == url || limit > @max_limit

    code, new_url = fetch_response(url)
    case code
    when '200'
      create_new_link(url)
    when '301', '308'
      handle_url_redirection(new_url, limit + 1)
    end
  end

  def create_new_link(url)
    new_link = Link.where(link_params.merge(url: URI.escape(url))).first_or_initialize
    new_link.editor_account = Account.hamster

    return unless new_link.save
    destroy_old_link
    @log.info("Replaced project link #{@link.id}(#{@link.url}) with new link #{new_link.id}(#{new_link.url})")
  end

  def destroy_old_link
    @link.editor_account = Account.hamster
    @link.update_attributes!(deleted: true)
    create_edit = CreateEdit.where(target_type: 'Link', target_id: @link.id).first
    create_edit.undo!(Account.hamster) if create_edit
    BrokenLink.where(link_id: @link.id).destroy_all
  end

  def link_params
    { project_id: @link.project_id, title: @link.title, link_category_id: @link.link_category_id }
  end
end
