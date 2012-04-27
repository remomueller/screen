module ApplicationHelper
  def cancel
    link_to image_tag('gentleface/16/cancel.png', alt: '') + 'Cancel', URI.parse(request.referer.to_s).path.blank? ? root_path : (URI.parse(request.referer.to_s).path), class: 'btn btn-danger'
  end

  # Prints out '6 hours ago, Yesterday, 2 weeks ago, 5 months ago, 1 year ago'
  def recent_activity(past_time)
    return '' unless past_time.kind_of?(Time)
    time_ago_in_words(past_time)
    seconds_ago = (Time.now - past_time)
    color = if seconds_ago < 60.minute then "#6DD1EC"
    elsif seconds_ago < 1.day then "#ADDD1E"
    elsif seconds_ago < 2.day then "#CEDC34"
    elsif seconds_ago < 1.week then "#CEDC34"
    elsif seconds_ago < 1.month then "#DCAA24"
    elsif seconds_ago < 1.year then "#C2692A"
    else "#AA2D2F"
    end
    "<span style='color:#{color};font-weight:bold;font-variant:small-caps;'>#{time_ago_in_words(past_time)} ago</span>".html_safe
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
      past_time.strftime("<b>Today</b> at %I:%M %p").html_safe
    elsif past_time.year == Date.today.year
      past_time.strftime("on %b %d at %I:%M %p")
    else
      past_time.strftime("on %b %d, %Y at %I:%M %p")
    end
  end

  def sort_field_helper(order, sort_field, display_name, search_form_id  = 'search_form')
    result = ''
    if order == sort_field
      result = "<span class='selected'>#{display_name} #{ link_to_function('&raquo;'.html_safe, "$('#order').val('#{sort_field} DESC');$('##{search_form_id}').submit();", style: 'text-decoration:none')}</span>"
    elsif order == sort_field + ' DESC' or order.split(' ').first != sort_field
      result = "<span #{'class="selected"' if order == sort_field + ' DESC'}>#{display_name} #{link_to_function((order == sort_field + ' DESC' ? '&laquo;'.html_safe : '&laquo;&raquo;'.html_safe), "$('#order').val('#{sort_field}');$('##{search_form_id}').submit();", style: 'text-decoration:none')}</span>"
    end
    result
  end

  def pretty_phone(phone)
    digits = phone.to_s.gsub(/[^\d]/, '')
    if digits.size == 10
      digits[0..2] + "-" + digits[3..5] + "-" + digits[6..-1]
    elsif digits.size == 11
      digits[0] + "-" + digits[1..3] + "-" + digits[4..6] + "-" + digits[7..-1]
    else
      phone
    end
  end

end
