id = <%= @helpful.review.id %>
$container = $(".review_container[id^=review_list_#{ id }], [id^=review_summary_#{ id }]")
$container.find('.helpful_above').replaceWith("<%=j render 'reviews/helpful_count_status', review: @helpful.review %>")
$container.find('.helpful_below').replaceWith("<%=j render 'reviews/helpful_yes_or_no_links', review: @helpful.review %>")

App.Helpfuls.setupVoteLinks()
