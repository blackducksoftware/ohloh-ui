show_positions ||= false
show_about ||= false

xml.account do
  xml.id account.id
  xml.name account.name
  if show_about
    xml.about account.markup ? account.markup.raw : ''
  end
  xml.login account.login
  xml.created_at xml_date_to_time(account.created_at)
  xml.updated_at xml_date_to_time(account.updated_at)
  xml.homepage_url account.url
  xml.twitter_account account.twitter_account
  xml.url account_url(account, format: 'xml')
  xml.html_url account_url(account)
  xml.avatar_url "https://www.gravatar.com/avatar.php?gravatar_id=#{account.email_md5}"
  xml.email_sha1 Digest::SHA1.hexdigest("mailto:#{account.email}")
  xml.posts_count account.posts_count
  xml.location account.location
  xml.country_code account.country_code
  xml.latitude account.latitude
  xml.longitude account.longitude
  if account.person && account.person.kudo_score
    xml.kudo_score do
      xml.kudo_rank account.kudo_rank
      xml.position account.person.kudo_position
    end
  end
  if show_positions
    vita_fact = account.best_vita.try(:vita_fact)
    if vita_fact && vita_fact.name_language_facts.any?
      xml.languages do
        vita_fact.name_language_facts.each do |nlf|
          color = language_color(nlf.language.name)
          xml.language color: color do
            xml.name nlf.language.name
            xml.experience_months nlf.total_months
            xml.total_commits number_with_delimiter(nlf.total_commits)
            xml.total_lines_changed number_with_delimiter(nlf.total_activity_lines)
            cr = nlf.comment_ratio ? number_with_precision(nlf.comment_ratio.to_f * 100.0, precision: 1).to_s + '%' : '-'
            xml.comment_ratio cr
          end
        end
      end
    end
  end
  if account.badges.any?
    xml.badges do
      account.badges.each do |badge|
        decorator = BadgeDecorator.new(badge)
        xml.badge do
          xml.name badge.name
          xml.level badge.level
          xml.description badge.short_desc
          xml.image_url decorator.image_url(request)
          xml.pips_url decorator.pips_url(request)
        end
      end
    end
  end
end
