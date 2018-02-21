module AvatarHelper
  def avatar_for(who, options = {})
    return '' unless who
    title = (options[:title] == true) ? avatar_title(who) : options[:title]
    attributes = { title: title, class: options[:class] || 'avatar' }
    url = options[:url] || avatar_path(who)
    link_to avatar_img_for(who, options[:size] || 32), url, attributes
  end

  def avatar_img_path(who, size = 32)
    return gravatar_url(who.email_md5, size) if who.is_a? Account
    return gravatar_url(who.account.email_md5, size) if who.respond_to?(:account) && who.account
    anonymous_image_path(size)
  end

  def avatar_img_for(who, size = 32)
    return '' unless who
    image_tag avatar_img_path(who, size), style: "width: #{size}px; height: #{size}px;", class: 'avatar'
  end

  def avatar_path(who)
    return '#' unless who
    case who
    when Account
      account_path(who)
    when Person
      who.account_id ? account_path(who.account) : project_contributor_path(who.project_id, who.id)
    end
  end

  def avatar_small_laurels(rank)
    avatar_laurels_img(rank, 'sm_laurel').html_safe
  end

  def avatar_laurels(rank)
    avatar_laurels_img(rank, 'laurel').html_safe
  end

  def avatar_tiny_laurels(rank)
    avatar_laurels_img(rank, 'tn_laurel').html_safe
  end

  private

  def avatar_default_size(size)
    return 32 if size <= 32
    return 40 if size <= 40
    80
  end

  def gravatar_url(md5, size)
    default_url = if ActionController::Base.asset_host.blank?
                    'https%3a%2f%2fopenhub.net'
                  else
                    "http#{'s' if request && request.ssl?}%3a%2f%2f#{ActionController::Base.asset_host}"
                  end
    default_url << "%2fanon#{avatar_default_size(size)}.gif"
    gravatar_host = 'https://gravatar.com'
    "#{gravatar_host}/avatar/#{md5}?&s=#{size}&rating=PG&d=#{default_url}"
  end

  def anonymous_image_path(size)
    "anon/anon#{avatar_default_size(size)}.gif"
  end

  def avatar_title(who)
    return '' unless who
    case who
    when Account
      who.name
    when Person
      who.effective_name
    end
  end

  def avatar_laurels_img(rank, imag_base)
    "<img src='" + image_path("icons/#{imag_base}_#{rank || 1}.png") + "' alt='KudoRank #{rank || 1}'/>".html_safe
  end
end
