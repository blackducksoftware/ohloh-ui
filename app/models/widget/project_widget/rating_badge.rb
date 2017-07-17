class ProjectWidget::RatingBadge < ProjectWidget
  def short_nice_name
    I18n.t('project_widgets.ratings_badge.short_nice_name')
  end

  def width
    245
  end

  def height
    50
  end

  def image
    image_data = [{ text: project.name.truncate(18).shellescape, align: :center }]
    image_data += [average_rating_text, ratings_text, reviews_text].compact
    WidgetBadge::Partner.create(image_data)
  end

  def position
    19
  end

  private

  def average_rating_text
    avg = "#{ApplicationController.helpers.number_with_precision(project.rating_average || 0, precision: 1)}/5.0"
    { text: I18n.t('project_widgets.ratings_badge.avg_rating', value: avg), align: :center }
  end

  def ratings_text
    rating_count = project.ratings.count
    rating = I18n.t('project_widgets.ratings_badge.rating').pluralize(rating_count)
    rating_text = I18n.t('project_widgets.ratings_badge.rating_text', value: rating_count.to_human, text: rating)
    { text: rating_text, align: :center } if rating_count
  end

  def reviews_text
    review_count = project.reviews.count
    review = I18n.t('project_widgets.ratings_badge.review').pluralize(review_count)
    review_text = I18n.t('project_widgets.ratings_badge.review_text', value: review_count.to_human, text: review)
    { text: review_text, align: :center } if review_count
  end
end
