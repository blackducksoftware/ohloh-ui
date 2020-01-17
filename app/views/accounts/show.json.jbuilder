# frozen_string_literal: true

show_positions = true
show_about = true

json.account do
  json.id @account.id
  json.name @account.name

  json.about(@account.markup ? @account.markup.raw : '') if show_about

  json.login @account.login
  json.call(@account, :created_at, :updated_at)
  json.homepage_url @account.url
  json.twitter_account @account.twitter_account
  json.url account_url(@account, format: 'json')
  json.html_url account_url(@account)
  json.avatar_url "http://www.gravatar.com/avatar.php?gravatar_id=#{@account.email_md5}"
  json.email_sha1 Digest::SHA1.hexdigest("mailto:#{@account.email}")
  json.posts_count @account.posts_count
  json.location @account.location
  json.country_code @account.country_code
  json.latitude @account.latitude
  json.longitude @account.longitude

  if @account.person&.kudo_score
    json.kudo_score do
      json.kudo_rank @account.kudo_rank
      json.position @account.person.kudo_position
    end
  end

  if show_positions
    account_analysis_fact = @account.best_account_analysis.try(:account_analysis_fact)
    if account_analysis_fact&.name_language_facts&.any?
      json.languages account_analysis_fact.name_language_facts do |nlf|
        json.name nlf.language.name
        json.experience_months nlf.total_months
        json.total_commits number_with_delimiter(nlf.total_commits)
        json.total_lines_changed number_with_delimiter(nlf.total_activity_lines)
        cr = nlf.comment_ratio ? number_with_precision(nlf.comment_ratio.to_f * 100.0, precision: 1).to_s + '%' : '-'
        json.comment_ratio cr
      end
    end
  end

  if @account.badges.any?
    json.badges @account.badges do |badge|
      decorator = BadgeDecorator.new(badge)
      json.name badge.name
      json.level badge.level
      json.description badge.short_desc
      json.image_url decorator.image_url(request)
      json.pips_url decorator.pips_url(request)
    end
  end
end
