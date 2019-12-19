# frozen_string_literal: true

xml.channel do
  xml.title 'Recent Posts | OpenHub'
  if params[:query].blank? && params[:sort].blank?
    xml.link @account_base_url
  else
    xml.link @account_base_url + "?query=#{params[:query]}&sort=#{params[:sort]}"
  end
  xml.language 'en-us'
  xml.ttl 60
  xml << render(partial: 'posts/posts.atom.builder', collection: @posts) if @account.posts.count.positive?
end
