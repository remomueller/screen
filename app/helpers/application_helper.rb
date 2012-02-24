module ApplicationHelper
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
end
