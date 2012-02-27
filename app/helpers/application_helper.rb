module ApplicationHelper

  def cancel
    link_to image_tag('gentleface/16/cancel.png', alt: '') + 'Cancel', URI.parse(request.referer.to_s).path.blank? ? root_path : (URI.parse(request.referer.to_s).path), class: 'button negative'
  end

  def simple_date(past_date)
    return '' if past_date.blank?
    if past_date == Date.today
      'Today'
    elsif past_date == Date.today - 1.day
      'Yesterday'
    elsif past_date == Date.today + 1.day
      'Tomorrow'
    elsif past_date.year == Date.today.year
      past_date.strftime("%b %d")
    else
      past_date.strftime("%b %d, %Y")
    end
  end

  def simple_weekday(date)
    return '' unless date.kind_of?(Time) or date.kind_of?(Date)
    date.strftime("%a")
  end

  def simple_date_and_weekday(date)
    [simple_date(date), simple_weekday(date)].select{|i| not i.blank?}.join(', ')
  end

  def simple_time(past_time)
    return '' if past_time.blank?
    if past_time.to_date == Date.today
      past_time.strftime("at %I:%M %p")
    elsif past_time.year == Date.today.year
      past_time.strftime("on %b %d at %I:%M %p")
    else
      past_time.strftime("on %b %d, %Y at %I:%M %p")
    end
  end
end
