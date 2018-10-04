desc 'Checks broken active links in active projects'
task check_broken_links: :environment do
  Link.joins(:project).where(deleted: false, projects: { deleted: false }).select(:id, :url).each do |link|
    next if valid_url?(link.url)
    broken_link = BrokenLink.find_or_initialize_by(link_id: link.id)
    if broken_link.changed?
      broken_link.save
    else
      broken_link.touch
    end
  end
  BrokenLink.where('updated_at < ?', 1.day.ago).destroy_all
end

def valid_url?(url)
  uri = URI.parse(url)
  if uri.is_a?(URI::HTTP) && !uri.host.nil?
    res = Net::HTTP.get_response(u)
    ['200'].include?(res.code)
  else
    false
  end
rescue URI::InvalidURIError
  false
end
