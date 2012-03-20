desc 'Flag Priority followups for patients'

task flag_priority: :environment do
  # if latest_event = call and call_response = "Scheduled for Embletta" then priority = 1

  # if latest_event = call and call_response = "Deferred" then priority = 1

  # if latest_event = call and call_response = "Left Message/Voicemail" then priority = 1

  call_response_ids = Choice.where(category: 'call response', name: ['Deferred', 'Left Message/Voicemail']).pluck(:id)

  embletta_call_response_ids = Choice.where(category: 'call response', name: ['Scheduled for Embletta']).pluck(:id)
  embletta_evaluation_ids = Choice.where(category: 'administration type', name: ['Embletta']).pluck(:id).collect{|id| id.to_s}

  baseline_visit_ids = Choice.where(category: 'visit type', name: ['Baseline']).pluck(:id).collect{|id| id.to_s}
  mo2_call_ids = Choice.where(category: 'call type', name: ['2-month']).pluck(:id).collect{|id| id.to_s}

  continued_outcome_ids = Choice.where(category: 'visit outcome', name: ['continued']).pluck(:id)

  # In essence, if someone has a baseline visit, the visit occurred more than 68 days ago, and no "2-Month" Call exists, then the patient should be flagged. 68 days = two months + 7 days, after which the "2-month" call would be out of window (protocol deviation)
  # if latest_event = baseline visit and (today - visit_date) > 68 and call_type = 2-month does not exist then priority = 1


  Patient.current.each do |patient|
    messages = []
    priority = 0
    bump_priority = false

    if call = patient.calls.order('call_time').last and call_response_ids.include?(call.response.to_i)
      priority += 1
      bump_priority = true
      messages << "Latest Call is #{call.response_name}"
    end

    if call = patient.calls.order('call_time').last and embletta_call_response_ids.include?(call.response.to_i) and patient.evaluations.where(administration_type: embletta_evaluation_ids).size == 0
      priority += 1
      bump_priority = true
      messages << "Latest Call is #{call.response_name} and no Embletta Administered"
    end


    if visit = patient.visits.where(visit_type: baseline_visit_ids).first and continued_outcome_ids.include?(visit.outcome.to_i) and patient.calls.where(call_type: mo2_call_ids).size == 0 and (Date.today - visit.visit_date).to_i > 68
      priority += 1
      bump_priority = true
      messages << "Baseline Visit and no 2-month Call after 68 days"
    end


    if bump_priority
      patient.update_attributes priority: patient.priority + priority, priority_message: messages.join(', ')
    else
      patient.update_attributes priority: 0, priority_message: ''
    end
  end
end
