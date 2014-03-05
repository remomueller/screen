class PrescreensController < ApplicationController
  before_action :authenticate_user!
  before_action :check_screener_or_subject_handler, except: [ :bulk, :import ]
  before_action :check_screener, only: [ :bulk, :import ]

  before_action :set_prescreen, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_prescreen, only: [ :show, :edit, :update, :destroy ]

  def bulk
  end

  def import
    count_hash = Prescreen.process_bulk(params, current_user)
    notices = []
    alerts = []
    count_hash.each do |key, count|
      if key.to_s == 'ignored prescreen'
        alerts << "#{count} prescreen#{'s' unless count == 1} ignored" if count > 0
      else
        notices << "#{count} #{key}#{'s' unless count == 1} added" if (count > 0 and key.to_s != 'prescreen') or key.to_s == 'prescreen'
      end
    end
    redirect_to prescreens_path, notice: (notices.size > 0 ? notices.join(', ') : nil), alert: (alerts.size > 0 ? alerts.join(', ') : nil)
  end

  # GET /prescreens
  # GET /prescreens.json
  def index
    @order = scrub_order(Prescreen, params[:order], 'prescreens.doctor_id, prescreens.visit_at DESC')
    prescreen_scope = Prescreen.current.order(@order)

    if params[:mrn].to_s.split(',').size > 1
      prescreen_scope = prescreen_scope.with_subject_code(params[:mrn].to_s.gsub(/\s/, '').split(','))
    else
      params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
        prescreen_scope = prescreen_scope.with_mrn(term) unless term.blank?
      end
    end

    prescreen_scope = prescreen_scope.subject_code_not_blank unless current_user.screener?
    prescreen_scope = prescreen_scope.with_eligibility(params[:eligibility]) unless params[:eligibility].blank?
    prescreen_scope = prescreen_scope.with_no_calls if params[:not_called] == '1'

    visit_after = parse_date(params[:visit_after])
    visit_before = parse_date(params[:visit_before])

    prescreen_scope = prescreen_scope.visit_before(visit_before) unless visit_before.blank?
    prescreen_scope = prescreen_scope.visit_after(visit_after) unless visit_after.blank?

    @prescreens = prescreen_scope.page(params[:page]).per( 40 )
  end

  # GET /prescreens/1
  # GET /prescreens/1.json
  def show
  end

  # GET /prescreens/new?patient_id=1
  def new
    @prescreen = Prescreen.new(patient_id: params[:patient_id])
    redirect_to root_path unless @prescreen and @prescreen.patient.editable_by?(current_user)
  end

  # GET /prescreens/1/edit
  def edit
  end

  # POST /prescreens
  # POST /prescreens.json
  def create
    @prescreen = current_user.prescreens.new(prescreen_params)

    respond_to do |format|
      if @prescreen.save
        format.html { redirect_to @prescreen.patient, notice: 'Prescreen was successfully created.' }
        format.json { render action: 'show', status: :created, location: @prescreen }
      else
        format.html { render action: 'new' }
        format.json { render json: @prescreen.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /prescreens/1
  # PUT /prescreens/1.json
  def update
    respond_to do |format|
      if @prescreen.update(prescreen_params)
        format.html { redirect_to @prescreen, notice: 'Prescreen was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @prescreen.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /prescreens/1
  # DELETE /prescreens/1.json
  def destroy
    @prescreen.destroy

    respond_to do |format|
      format.html { redirect_to prescreens_path, notice: 'Prescreen was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

    def set_prescreen
      prescreen = Prescreen.find_by_id(params[:id])
      @prescreen = prescreen if prescreen and prescreen.patient.editable_by?(current_user)
    end

    def redirect_without_prescreen
      empty_response_or_root_path unless @prescreen
    end

    def prescreen_params
      params[:prescreen] ||= {}

      params[:visit_date] = parse_date(params[:visit_date])
      params[:visit_time] = Time.parse(params[:visit_time]) rescue Time.parse("12am")
      params[:visit_time] = Time.parse("12am") if params[:visit_time].blank?
      params[:prescreen][:visit_at] = Time.parse(params[:visit_date].strftime('%F') + " " + params[:visit_time].strftime('%T')) rescue ""
      params[:prescreen][:risk_factor_ids] ||= []

      params.require(:prescreen).permit(
        :patient_id, :clinic_id, :doctor_id, :visit_at, :visit_duration, :visit_units, :eligibility, :exclusion, :comments, [ :risk_factor_ids => [] ]
      )
    end

end
