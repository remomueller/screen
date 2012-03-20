desc 'Export a dictionary in CSV format.'
task :export_dictionary => :environment do
  time_stamp = Time.now.strftime("%Y%m%d %Ih%M%p")
  @dictionary_export_file = "tmp/#{DEFAULT_APP_NAME.downcase.gsub(/[^\da-zAz]/, '_')}_dictionary_import_#{time_stamp}.csv"
  CSV.open(@dictionary_export_file, "wb") do |csv|
    csv << ["#URI", "Namespace", "Short Name", "Description", "Concept Type", "Units", "Terms", "Internal Terms", "Parents", "Children", "Equivalent Concepts", "Similar Concepts", "Field Values", "Sensitivity", "Display Name", "Commonly Used", "Folder", "Calculation", "Source Name", "Source File", "Source Description"]
    uri = SITE_URL
    namespace = "screen"

    csv << [uri, namespace, 'patient_id', 'Patient', 'identifier', '', 'patient_id', 'id', '', '', '', '', '', 0, "Patient", 1, "Patients"]
    csv << [uri, namespace, 'patient_deleted', 'Patient Deleted', 'boolean', '', 'deleted', 'deleted', '', '', '', '', '', 0, "Patient Deleted", 1, "Patients"]
    csv << [uri, namespace, 'patient_priority', 'Patient Priority', 'continuous', '', 'patient_priority', 'priority', '', '', '', '', '', 0, "Patient Priority", 1, "Patients"]

    csv << [uri, namespace, 'prescreen_id', 'Prescreen', 'identifier', '', 'prescreen_id', 'id', '', '', '', '', '', 0, "Prescreen", 1, "Prescreens"]
    csv << [uri, namespace, 'prescreen_deleted', 'Prescreen Deleted', 'boolean', '', 'deleted', 'deleted', '', '', '', '', '', 0, "Prescreen Deleted", 1, "Prescreens"]
    csv << [uri, namespace, 'prescreen_visit_date', 'Visit Date', 'datetime', '', 'visit_date', 'visit_at', '', '', '', '', '', 0, "Visit Date", 1, "Prescreens"]


    csv << [uri, namespace, 'choice_id', 'Choice', 'categorical', '', 'choice_id', 'choice_id', '', '', '', '', '', 0, "Choice", 1, "Choices"]

    Choice.current.group_by(&:category).each do |category, choices|
      category_gsub = category.gsub(/[^\da-zA-Z]/, '_')
      csv << [uri, namespace, "choice_category_#{category_gsub}", category.titleize, 'categorical', '', category_gsub, category_gsub, '#choice_id', '', '', '', '', 0, category.titleize, 1, "Choices"]
      choices.each do |choice|
        csv << [uri, namespace, "choice_#{choice.id}", choice.name, 'boolean', '', choice.name, choice.id, "#choice_category_#{category_gsub}", '', '', '', '', 0, choice.name, 0]
      end
    end



    # csv << [uri, namespace, 'sticky_status', 'Sticky Completed', 'boolean', '', 'completed', 'completed', '', '', '', '', '', 0, "Sticky Completed", 1, "Patients"]
    # csv << [uri, namespace, 'project_id', 'Project', 'categorical', '', 'project_id', 'project_id', '', '', '', '', '', 0, "Project", 1, "Patients"]
    # csv << [uri, namespace, 'tag_id', 'Tag', 'categorical', '', 'tag_id', 'tag_id', '', '', '', '', '', 0, "Tag", 1, "Patients"]
    # csv << [uri, namespace, 'due_date', 'Sticky Due Date', 'datetime', '', 'due_date', 'due_date', '', '', '', '', '', 0, "Sticky Due Date", 1, "Patients"]
    # csv << [uri, namespace, 'owner_id', 'Assigned To', 'categorical', '', 'owner_id', 'owner_id', '', '', '', '', '', 0, "Assigned To", 1, "Patients"]
    # csv << [uri, namespace, 'sticky_deleted', 'Sticky Deleted', 'boolean', '', 'deleted', 'deleted', '', '', '', '', '', 0, "Sticky Deleted", 1, "Patients"]

    # Tag.all.group_by(&:name).each do |tag_name, tags|
    #   csv << [uri, namespace, "tag_#{tags.first.id}", tag_name, 'boolean', '', tag_name, tags.collect{|t| t.id}.join('; '), '#tag_id', '', '', '', '', 0, tag_name, 0]
    # end

    # User.current.each do |user|
    #   csv << [uri, namespace, "user_#{user.id}", user.name, 'boolean', '', user.name, user.id, '#owner_id', '', '', '', '', 0, user.name, 0]
    # end

    # Project.current.each do |project|
    #   csv << [uri, namespace, "project_#{project.id}", project.name, 'boolean', '', project.name, project.id, '#project_id', '', '', '', '', 0, project.name, 0]
    # end

  end

end
