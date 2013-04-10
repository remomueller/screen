class MailingsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_screener_or_subject_handler, except: [ :bulk, :import ]
  before_action :check_screener, only: [ :bulk, :import ]
  before_action :set_mailing, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_mailing, only: [ :show, :edit, :update, :destroy ]


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

  # GET /mailings
  # GET /mailings.json
  def index
    @order = scrub_order(Mailing, params[:order], 'mailings.patient_id')
    mailing_scope = Mailing.current.order(@order)

    if params[:mrn].to_s.split(',').size > 1
      mailing_scope = mailing_scope.with_subject_code(params[:mrn].to_s.gsub(/\s/, '').split(','))
    else
      params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
        mailing_scope = mailing_scope.with_mrn(term) unless term.blank?
      end
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

    if params[:format] == 'originalcsv'
      generate_original_csv(mailing_scope)
      return
    elsif params[:format] == 'csv'
      generate_csv(mailing_scope)
      return
    end

    @mailings = mailing_scope.page(params[:page]).per(20) # (current_user.mailings_per_page)
  end

  # GET /mailings/1
  # GET /mailings/1.json
  def show
  end

  # GET /mailings/new?patient_id=1
  def new
    @mailing = Mailing.new(patient_id: params[:patient_id])
    redirect_to root_path unless @mailing and @mailing.patient.editable_by?(current_user)
  end

  # GET /mailings/1/edit
  def edit
  end

  # POST /mailings
  # POST /mailings.json
  def create
    @mailing = current_user.mailings.new(mailing_params)

    respond_to do |format|
      if @mailing.save
        format.html { redirect_to @mailing.patient, notice: 'Mailing was successfully created.' }
        format.json { render action: 'show', status: :created, location: @mailing }
      else
        format.html { render action: 'new' }
        format.json { render json: @mailing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /mailings/1
  # PUT /mailings/1.json
  def update
    respond_to do |format|
      if @mailing.update(mailing_params)
        format.html { redirect_to @mailing, notice: 'Mailing was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @mailing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mailings/1
  # DELETE /mailings/1.json
  def destroy
    @mailing.destroy

    respond_to do |format|
      format.html { redirect_to mailings_path, notice: 'Mailing was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

    def set_mailing
      mailing = Mailing.find_by_id(params[:id])
      @mailing = mailing if mailing and mailing.patient.editable_by?(current_user)
    end

    def redirect_without_mailing
      empty_response_or_root_path unless @mailing
    end

    def mailing_params
      params[:mailing] ||= {}

      [:sent_date, :response_date].each do |date|
        params[:mailing][date] = parse_date(params[:mailing][date])
      end

      params[:mailing][:risk_factor_ids] ||= []

      params.require(:mailing).permit(
        :patient_id, :doctor_id, :sent_date, :response_date, :berlin, :ess, :eligibility, :exclusion, :participation, :comments, [ :risk_factor_ids => [] ]
      )
    end

    def generate_original_csv(mailing_scope)
      @csv_string = CSV.generate do |csv|
        csv << ["Doctor", "Date of Mailing", "MRN", "Last Name", "First Proper", "Address1", "City", "State", "Zip Code", "Home Phone", "Day Phone"]
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
