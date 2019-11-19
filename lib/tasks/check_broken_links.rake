# frozen_string_literal: true

desc 'Checks broken active links in active projects'
task check_broken_links: :environment do
  Link.joins(:project).where(deleted: false, projects: { deleted: false }).select(:id, :url).find_each do |link|
    valid, error = valid_url(link.url)

    next if valid

    broken_link = BrokenLink.find_or_initialize_by(link_id: link.id)
    broken_link.error = error

    if broken_link.changed?
      broken_link.save
    else
      broken_link.touch
    end
  end
  BrokenLink.where('updated_at < ?', 1.month.ago).destroy_all
end

def valid_url(url)
  response = get_response(url)
  response.code == '200' ? true : [false, "#{response.code}: #{response.class}"]
rescue StandardError => e
  [false, e.class]
end

def get_response(url)
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 30
  http.open_timeout = 30
  http.use_ssl = (uri.scheme == 'https')
  request = Net::HTTP::Head.new(uri.request_uri)
  http.request(request)
end
