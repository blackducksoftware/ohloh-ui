class Feedback < ActiveRecord::Base
  scope :project_rating, ->(project_name, rating) { where(project_name: project_name, rating: rating) }
  scope :more_info, ->(more_info) { where(more_info: more_info) }
  scope :rating, ->(rating) { where(rating: rating) }

  def self.dashboard_stats(date, weekly = false)
    stats_hash = {}
    total_count = Feedback.all.count.to_f
    feedbacks = if weekly
                  Feedback.where(created_at: date.prev_day(6).beginning_of_day..date.end_of_day)
                else
                  Feedback.where(created_at: date.beginning_of_day..date.end_of_day)
                end
    feedbacks_count = feedbacks.count == 0 ? 1 : feedbacks.count.to_f
    fcp = ((feedbacks.count / total_count) * 100).round
    rating_count = { 'five_rating' => feedbacks.rating(5).count,
               'four_rating' => feedbacks.rating(4).count,
               'three_rating' => feedbacks.rating(3).count,
               'two_rating' => feedbacks.rating(2).count,
               'one_rating' => feedbacks.rating(1).count }
    rating = Feedback.rating_stats(rating_count, feedbacks_count)
    more_info = { 'yes' => ((feedbacks.more_info(1).count / feedbacks_count) * 100).round,
                  'no' => ((feedbacks.more_info(0).count / feedbacks_count) * 100).round }
    stats_hash.merge!('fcp' => fcp,
                      'rating_count' => rating_count,
                      'rating' => rating,
                      'more_info' => more_info,
                      'fc' => feedbacks.count,
                      'yes_info_c' => feedbacks.more_info(1).count)
  end

  def self.rating_stats(rating_count, feedbacks_count)
    { 'five_rating' => ((rating_count['five_rating'] / feedbacks_count) * 100).round,
      'four_rating' => ((rating_count['four_rating'] / feedbacks_count) * 100).round,
      'three_rating' => ((rating_count['three_rating'] / feedbacks_count) * 100).round,
      'two_rating' => ((rating_count['two_rating'] / feedbacks_count) * 100).round,
      'one_rating' => ((rating_count['one_rating'] / feedbacks_count) * 100).round }
  end

  def self.most_interested_stats
    most_interested = Hash[Feedback.all.group_by(&:project_id).sort_by { |_project_id, feedbacks| feedbacks.count }.reverse.first(3)]
    most_interested_list = {}
    most_interested.each do |project_id, feedbacks|
      most_interested_list.merge!(project_id => { 'avg_helpful' => (feedbacks.map(&:rating).sum / feedbacks.map(&:rating).size.to_f).round,
                                            'interested' => ((feedbacks.map(&:more_info).delete_if { |x| x == 0 }.count.to_f / feedbacks.map(&:more_info).count) * 100).round,
                                            'project_name' => feedbacks.map(&:project_name).uniq.first })
    end
    most_interested_list
  end
end
