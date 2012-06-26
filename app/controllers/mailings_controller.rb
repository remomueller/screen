class MailingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_screener_or_subject_handler, except: [:bulk, :import]
  before_filter :check_screener, only: [:bulk, :import]

  def bulk

  end

  def import
    count_hash = Mailing.process_bulk(params, current_user)
    notices = []
    alerts = []
    count_hash.each do |key, count|
      if key.to_s == 'ignored mailing'
        alerts << "#{count} mailing#{'s' unless count == 1} ignored" if count > 0
      else
        notices << "#{count} #{key}#{'s' unless count == 1} added" if (count > 0 and key.to_s != 'mailing') or key.to_s == 'mailing'
      end
    end
    redirect_to mailings_path, notice: (notices.size > 0 ? notices.join(', ') : nil), alert: (alerts.size > 0 ? alerts.join(', ') : nil)
  end

  def index
    # current_user.update_attribute :mailings_per_page, params[:mailings_per_page].to_i if params[:mailings_per_page].to_i >= 10 and params[:mailings_per_page].to_i <= 200
    mailing_scope = Mailing.current # current_user.all_viewable_mailings
    params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
      mailing_scope = mailing_scope.with_mrn(term) unless term.blank?
    end

    mailing_scope = mailing_scope.subject_code_not_blank unless current_user.screener?
    mailing_scope = mailing_scope.with_eligibility(params[:eligibility]) unless params[:eligibility].blank?

    @sent_after = parse_date(params[:sent_after])
    @sent_before = parse_date(params[:sent_before])
    mailing_scope = mailing_scope.sent_before(@sent_before) unless @sent_before.blank?
    mailing_scope = mailing_scope.sent_after(@sent_after) unless @sent_after.blank?

    @response_after = parse_date(params[:response_after])
    @response_before = parse_date(params[:response_before])
    mailing_scope = mailing_scope.response_before(@response_before) unless @response_before.blank?
    mailing_scope = mailing_scope.response_after(@response_after) unless @response_after.blank?

    mailing_scope = mailing_scope.exclude_ineligible if params[:ineligible] == '1'

    @order = Mailing.column_names.collect{|column_name| "mailings.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "mailings.patient_id"
    mailing_scope = mailing_scope.order(@order)

    if params[:format] == 'originalcsv'
      generate_original_csv(mailing_scope)
      return
    elsif params[:format] == 'csv'
      generate_csv(mailing_scope)
      return
    end

    @mailing_count = mailing_scope.count
    @mailings = mailing_scope.page(params[:page]).per(20) # (current_user.mailings_per_page)
  end

  def show
    @mailing = Mailing.find_by_id(params[:id])
    redirect_to root_path unless @mailing and @mailing.patient.editable_by?(current_user)
  end

  def new
    @mailing = Mailing.new(patient_id: params[:patient_id])
    redirect_to root_path unless @mailing and @mailing.patient.editable_by?(current_user)
  end

  def edit
    @mailing = Mailing.find_by_id(params[:id])
    redirect_to root_path unless @mailing and @mailing.patient.editable_by?(current_user)
  end

  def create
    params[:mailing] ||= {}
    [:sent_date, :response_date].each do |date|
      params[:mailing][date] = parse_date(params[:mailing][date])
    end

    # params[:mailing][:sent_date] = Date.strptime(params[:mailing][:sent_date], "%m/%d/%Y") if params[:mailing] and not params[:mailing][:sent_date].blank?
    # params[:mailing][:response_date] = Date.strptime(params[:mailing][:response_date], "%m/%d/%Y") if params[:mailing] and not params[:mailing][:response_date].blank?

    @mailing = current_user.mailings.new(params[:mailing])

    if @mailing.save
      redirect_to @mailing.patient, notice: 'Mailing was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    params[:mailing] ||= {}
    [:sent_date, :response_date].each do |date|
      params[:mailing][date] = parse_date(params[:mailing][date])
    end

    # params[:mailing][:sent_date] = Date.strptime(params[:mailing][:sent_date], "%m/%d/%Y") if params[:mailing] and not params[:mailing][:sent_date].blank?
    # params[:mailing][:response_date] = Date.strptime(params[:mailing][:response_date], "%m/%d/%Y") if params[:mailing] and not params[:mailing][:response_date].blank?

    params[:mailing][:risk_factor_ids] ||= []

    @mailing = Mailing.find_by_id(params[:id])

    if @mailing and @mailing.patient.editable_by?(current_user)
      if @mailing.update_attributes(params[:mailing])
        redirect_to @mailing, notice: 'Mailing was successfully updated.'
      else
        render action: "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @mailing = Mailing.find_by_id(params[:id])
    if @mailing and @mailing.patient.editable_by?(current_user)
      @mailing.destroy
      redirect_to mailings_path, notice: 'Mailing was successfully deleted.'
    else
      redirect_to root_path
    end
  end

  private

  def generate_original_csv(mailing_scope)
    @csv_string = CSV.generate do |csv|
      csv << ["Cardiologist", "Date of Mailing", "MRN", "Last Name", "First Proper", "Address1", "City", "State", "Zip Code", "Home Phone", "Day Phone"]
      mailing_scope.each do |mailing|
        csv << [
          mailing.doctor.name,
          mailing.sent_date.strftime("%m/%d/%Y"),
          mailing.patient.phi_mrn(current_user),
          mailing.patient.phi_last_name(current_user),
          mailing.patient.phi_first_name(current_user),
          mailing.patient.phi_address1(current_user),
          mailing.patient.phi_city(current_user),
          mailing.patient.phi_state(current_user),
          mailing.patient.phi_zip(current_user),
          pretty_phone(mailing.patient.phi_phone_home(current_user)),
          pretty_phone(mailing.patient.phi_phone_day(current_user))
        ]
      end
    end
    send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                          disposition: "attachment; filename=\"Mailings #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.csv\""
  end

  def generate_csv(mailing_scope)
    @csv_string = CSV.generate do |csv|
      csv << ["Patient ID", "Subject Code", "Sent Date", "Response Date", "Berlin", "ESS", "Eligibility", "Participation", "Participation Code", "Exclusion", "Exclusion Code", "Comments"]
      mailing_scope.each do |mailing|
        csv << [
          mailing.patient.id,
          mailing.patient.subject_code,
          mailing.sent_date.strftime("%Y-%m-%d"),
          mailing.response_date ? mailing.response_date.strftime("%Y-%m-%d") : '',
          mailing.berlin,
          mailing.ess,
          mailing.eligibility,
          mailing.participation_name,
          mailing.participation,
          mailing.exclusion_name,
          mailing.exclusion,
          mailing.comments
        ]
      end
    end
    send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                          disposition: "attachment; filename=\"Mailings #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.csv\""
  end

end
