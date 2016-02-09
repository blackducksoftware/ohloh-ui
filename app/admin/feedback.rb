ActiveAdmin.register Feedback do

  #belongs_to :project, finder: :find_by_vanity_url!, optional: true

  actions :index, :dashboard, :show, :project
  menu false
  filter :rating, as: :select, collection: [['Not Really Helpful', 1],
                                            ['Slightly Helpful', 2],
                                            ['Somewhat Helpful', 3],
                                            ['Very Helpful', 4],
                                            ['Extremely Helpful', 5]].reverse
  filter :more_info, as: :select, collection: [['Yes', 1],
                                               ['No', 0]]
  filter :uuid
  #filter :vanity_url, as: :string, label: 'PROJECT NAME'
  filter :created_at

  action_item do
    link_to 'Listing View', admin_feedbacks_path
  end

  index do
    column :id do |feedback|
      link_to feedback.id, admin_feedback_path(feedback), target: '_blank'
    end
    column :rating
    column :more_info do |feedback|
      feedback.more_info == 1 ? 'Y' : 'N'
    end
    column :project_name
    column :created_at
  end

  collection_action :project, method: :get do
    @feedbacks = Feedback.where(uuid: params[:uuid])
    @collection = @feedbacks.page(params[:page]).per(20)
    redirect_to admin_feedbacks_path('q' => { 'uuid_equals' => params[:uuid] })
  end

  collection_action :dashboard, method: :get do
    today_stats_hash = Feedback.dashboard_stats(DateTime.now.in_time_zone(Time.zone))
    weekly_stats_hash = Feedback.dashboard_stats(DateTime.now.in_time_zone(Time.zone), true)
    most_interested_hash = Feedback.most_interested_stats
    render 'dashboard', locals: { today_stats_hash: today_stats_hash,
                                  weekly_stats_hash: weekly_stats_hash,
                                  most_interested_hash: most_interested_hash }
  end

  collection_action :dashboard_stats, method: :get do
    stats_hash = {}
    today_stats_hash = Feedback.dashboard_stats(DateTime.now.in_time_zone(Time.zone))
    weekly_stats_hash = Feedback.dashboard_stats(DateTime.now.in_time_zone(Time.zone), true)
    stats_hash.merge!('weekly_rating' => weekly_stats_hash['rating'], 'today_rating' => today_stats_hash['rating'])
    render json: { stats_hash: stats_hash }
  end
end
