xml.channel do
  xml.title "Recent Posts | OpenHub"
  xml.link $account_base_url if params[:query].blank? && params[:sort].blank?
  xml.link $account_base_url + "?query=#{params[:query]}&sort=#{params[:sort]}" if params[:query].present? && params[:sort].present?
  xml.language 'en-us'
  xml.ttl 60
  xml << render(partial: 'posts/posts.atom.builder', collection: @posts) if @account.posts.count > 0
end