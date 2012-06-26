desc 'Export a dictionary in CSV format.'
task :export_dictionary => :environment do
  time_stamp = Time.now.strftime("%Y%m%d %Ih%M%p")
  @dictionary_export_file = "tmp/#{DEFAULT_APP_NAME.downcase.gsub(/[^\da-zAz]/, '_')}_dictionary_import_#{time_stamp}.csv"
  CSV.open(@dictionary_export_file, "wb") do |csv|
    csv << ["#URI", "Namespace", "Short Name", "Description", "Concept Type", "Units", "Terms", "Internal Terms", "Parents", "Children", "Equivalent Concepts", "Similar Concepts", "Field Values", "Sensitivity", "Display Name", "Commonly Used", "Folder", "Calculation", "Source Name", "Source File", "Source Description"]
    uri = SITE_URL
    namespace = "screen"

    # csv << [uri, namespace, 'patient_id', 'Patient', 'identifier', '', 'patient_id', 'id', '', '', '', '', '', 0, "Patient", 1, "Patients"]
    csv << [uri, namespace, 'patient_priority', 'Patient Priority', 'continuous', '', 'patient_priority', 'priority', '', '', '', '', '', 0, "Patient Priority", 1, "Patients"]

    models = ['patient', 'prescreen', 'mailing', 'call', 'evaluation', 'visit']

    # Identifiers
    models.each do |model|
      csv << [uri, namespace, "#{model}_id", model.titleize, 'identifier', '', "#{model}_id", 'id', '', '', '', '', '', 0, model.titleize, 1, model.titleize.pluralize]
    end

    # Deleted Flag booleans
    models.each do |model|
      boolean = 'deleted'
      csv << [uri, namespace, "#{model}_#{boolean}", "#{model} #{boolean}".titleize, 'boolean', '', "#{model}_#{boolean}", boolean, '', '', '', '', '', 0, "#{model} #{boolean}".titleize, 1, model.titleize.pluralize]
    end

    # Dates and Date Times
    models_and_dates = [
      ['prescreen', 'visit_at'],
      ['mailing', 'sent_date'],
      ['mailing', 'response_date'],
      ['call', 'call_time'],
      ['evaluation', 'administration_date'],
      ['evaluation', 'receipt_date'],
      ['evaluation', 'scored_date'],
      ['visit', 'visit_date']
    ]

    models_and_dates.each do |model, attribute|
      csv << [uri, namespace, "#{model}_#{attribute}", attribute.titleize, 'datetime', '', attribute, attribute, '', '', '', '', '', 0, "#{model} #{attribute}".titleize, 1, model.titleize.pluralize]
    end

    models_and_continuous = [
      ['mailing', 'ess'],
      ['mailing', 'berlin'],
      ['call', 'ess'],
      ['call', 'berlin'],
      ['evaluation', 'ahi']
    ]

    models_and_continuous.each do |model, attribute|
      csv << [uri, namespace, "#{model}_#{attribute}", attribute.titleize, 'continuous', '', attribute, attribute, '', '', '', '', '', 0, "#{model} #{attribute}".titleize, 1, model.titleize.pluralize]
    end

    # Choice.current.group_by(&:category).each do |category, choices|
    #   category_gsub = category.gsub(/[^\w]/, '_')
    #   csv << [uri, namespace, "choice_category_#{category_gsub}", category.titleize, 'categorical', '', category_gsub, category_gsub, '', '', '', '', '', 0, category.titleize, 1, "Choices"]
    #   choices.each do |choice|
    #     csv << [uri, namespace, "choice_#{choice.id}", choice.name, 'boolean', '', choice.name, choice.id, "#choice_category_#{category_gsub}", '', '', '', '', 0, choice.name, 0]
    #   end
    # end

    [
      ['prescreen', 'eligibility', Prescreen::ELIGIBILITY],
      ['prescreen', 'doctor_id', Doctor.all.collect{|d| [d.name, d.id.to_s]}],
      ['prescreen', 'clinic_id', Clinic.all.collect{|c| [c.name, c.id.to_s]}],
      ['prescreen', 'exclusion', Choice.where(category: 'exclusion').collect{|c| [c.name, c.id.to_s]}],
      ['mailing', 'eligibility', Mailing::ELIGIBILITY],
      ['mailing', 'doctor_id', Doctor.all.collect{|d| [d.name, d.id.to_s]}],
      ['mailing', 'participation', Choice.where(category: 'participation').collect{|c| [c.name, c.id.to_s]}],
      ['mailing', 'exclusion', Choice.where(category: 'exclusion').collect{|c| [c.name, c.id.to_s]}],
      ['call', 'eligibility', Call::ELIGIBILITY],
      ['call', 'direction', Call::CALL_DIRECTION],
      ['call', 'call_type', Choice.where(category: 'call type').collect{|c| [c.name, c.id.to_s]}],
      ['call', 'response', Choice.where(category: 'call response').collect{|c| [c.name, c.id.to_s]}],
      ['evaluation', 'eligibility', Evaluation::ELIGIBILITY],
      ['evaluation', 'status', Evaluation::STATUS],
      ['evaluation', 'source', Evaluation.pluck(:source).collect{|s| [s,s]}],
      ['evaluation', 'administration_type', Choice.where(category: 'administration type').collect{|c| [c.name, c.id.to_s]}],
      ['evaluation', 'evaluation_type', Choice.where(category: 'evaluation type').collect{|c| [c.name, c.id.to_s]}],
      ['evaluation', 'exclusion', Choice.where(category: 'exclusion').collect{|c| [c.name, c.id.to_s]}],
      ['visit', 'outcome', Choice.where(category: 'visit outcome').collect{|c| [c.name, c.id.to_s]}],
      ['visit', 'visit_type', Choice.where(category: 'visit type').collect{|c| [c.name, c.id.to_s]}]
    ].each do |variable, attribute, children|
      csv << [uri, namespace, "#{variable}_#{attribute}", "#{variable.titleize} #{attribute.titleize}", 'categorical', '', attribute, attribute, '', '', '', '', '', 0, "#{variable.titleize} #{attribute.titleize}", 1, variable.titleize.pluralize]
      children.each do |name, value|
        unless value.blank?
          value_shortname = "#{variable}_#{attribute}_#{value.gsub(/[^\w]/, '_')}"
          csv << [uri, namespace, value_shortname, "#{variable.titleize} #{attribute.titleize} - #{name}", 'boolean', '', value, value, "##{variable}_#{attribute}", '', '', '', '', 0, name, 0]
        end
      end
    end

  end

end
