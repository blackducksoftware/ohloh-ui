# frozen_string_literal: true

@account_base_url = "http://#{request.host_with_port}/accounts/#{@account.login}#{all_posts_path}" if @account
@base_url = "http://#{request.host_with_port}#{all_posts_path}"

atom_feed do |feed|
  feed.instruct!
  feed.rss do
    if @account.present? && @account.posts.count >= 0
      xml << render(partial: 'posts/account_header.atom.builder').gsub(/^/, '   ')
    else
      xml.channel do
        feed.title 'Recent Posts | OpenHub'
        feed.link @base_url if params[:query].blank? && params[:sort].blank?
        if params[:query].present? && params[:sort].present?
          feed.link @base_url + "?query=#{params[:query]}&sort=#{params[:sort]}"
        end
        feed.language 'en-us'
        feed.ttl 60
        xml << render(partial: 'posts/posts.atom.builder', collection: @posts).gsub(/^/, '      ')
      end
    end
  end
end
