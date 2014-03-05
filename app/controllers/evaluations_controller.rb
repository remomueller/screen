class EvaluationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_screener_or_subject_handler
  before_action :set_evaluation, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_evaluation, only: [ :show, :edit, :update, :destroy ]

  # GET /evaluations
  # GET /evaluations.json
  def index
    @order = scrub_order(Evaluation, params[:order], 'evaluations.patient_id')
    evaluation_scope = Evaluation.current.order(@order)

    if params[:mrn].to_s.split(',').size > 1
      evaluation_scope = evaluation_scope.with_subject_code(params[:mrn].to_s.gsub(/\s/, '').split(','))
    else
      params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
        evaluation_scope = evaluation_scope.with_mrn(term) unless term.blank?
      end
    end

    evaluation_scope = evaluation_scope.subject_code_not_blank unless current_user.screener?
    evaluation_scope = evaluation_scope.with_eligibility(params[:eligibility]) unless params[:eligibility].blank?

    @administration_after = parse_date(params[:administration_after])
    @administration_before = parse_date(params[:administration_before])
    evaluation_scope = evaluation_scope.administration_before(@administration_before) unless @administration_before.blank?
    evaluation_scope = evaluation_scope.administration_after(@administration_after) unless @administration_after.blank?

    @receipt_after = parse_date(params[:receipt_after])
    @receipt_before = parse_date(params[:receipt_before])
    evaluation_scope = evaluation_scope.receipt_before(@receipt_before) unless @receipt_before.blank?
    evaluation_scope = evaluation_scope.receipt_after(@receipt_after) unless @receipt_after.blank?

    @scored_after = parse_date(params[:scored_after])
    @scored_before = parse_date(params[:scored_before])
    evaluation_scope = evaluation_scope.scored_before(@scored_before) unless @scored_before.blank?
    evaluation_scope = evaluation_scope.scored_after(@scored_after) unless @scored_after.blank?

    evaluation_scope = evaluation_scope.where( administration_type: params[:administration_type] ) unless params[:administration_type].blank?
    evaluation_scope = evaluation_scope.where( evaluation_type: params[:evaluation_type] ) unless params[:evaluation_type].blank?

    if params[:format] == 'csv'
      generate_csv(evaluation_scope)
      return
    end

    @evaluations = evaluation_scope.page(params[:page]).per( 40 )
  end

  # GET /evaluations/1
  # GET /evaluations/1.json
  def show
    @evaluation = Evaluation.find_by_id(params[:id])
    redirect_to root_path unless @evaluation and @evaluation.patient.editable_by?(current_user)
  end

  # GET /evaluations/new?patient_id=1
  def new
    @evaluation = Evaluation.new(patient_id: params[:patient_id])
    redirect_to root_path unless @evaluation and @evaluation.patient.editable_by?(current_user)
  end

  # GET /evaluations/1/edit
  def edit
    @evaluation = Evaluation.find_by_id(params[:id])
    redirect_to root_path unless @evaluation and @evaluation.patient.editable_by?(current_user)
  end

  # POST /evaluations
  # POST /evaluations.json
  def create
    @evaluation = current_user.evaluations.new(evaluation_params)

    respond_to do |format|
      if @evaluation.save
        format.html { redirect_to @evaluation.patient, notice: 'Evaluation was successfully created.' }
        format.json { render action: 'show', status: :created, location: @evaluation }
      else
        format.html { render action: 'new' }
        format.json { render json: @evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /evaluations/1
  # PUT /evaluations/1.json
  def update
    respond_to do |format|
      if @evaluation.update(evaluation_params)
        format.html { redirect_to @evaluation, notice: 'Evaluation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /evaluations/1
  # DELETE /evaluations/1.json
  def destroy
    @evaluation.destroy

    respond_to do |format|
      format.html { redirect_to evaluations_path, notice: 'Evaluation was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

    def set_evaluation
      evaluation = Evaluation.find_by_id(params[:id])
      @evaluation = evaluation if evaluation and evaluation.patient.editable_by?(current_user)
    end

    def redirect_without_evaluation
      empty_response_or_root_path unless @evaluation
    end

    def evaluation_params
      params[:evaluation] ||= {}

      [:administration_date, :expected_receipt_date, :receipt_date, :storage_date, :reimbursement_form_date, :scored_date].each do |date|
        params[:evaluation][date] = parse_date(params[:evaluation][date])
      end

      params.require(:evaluation).permit(
        :patient_id, :administration_type, :evaluation_type, :administration_date, :source, :embletta_unit_number, :expected_receipt_date, :receipt_date, :storage_date, :subject_notified, :reimbursement_form_date, :scored_date, :ahi, :eligibility, :exclusion, :status, :comments
      )
    end

    def generate_csv(evaluation_scope)
      @csv_string = CSV.generate do |csv|
        csv << ["Patient ID", "Subject Code", "Administration Type", "Evaluation Type", "Source", "Administration Date", "Receipt Date", "Scored Date", "AHI", "Eligibility", "Exclusion", "Exclusion Code", "Status", "Comments"]
        evaluation_scope.each do |evaluation|
          csv << [
            evaluation.patient.id,
            evaluation.patient.subject_code,
            evaluation.administration_type_name,
            evaluation.evaluation_type_name,
            evaluation.source,
            evaluation.administration_date.strftime("%Y-%m-%d"),
            evaluation.receipt_date ? evaluation.receipt_date.strftime("%Y-%m-%d") : '',
            evaluation.scored_date ? evaluation.scored_date.strftime("%Y-%m-%d") : '',
            evaluation.ahi,
            evaluation.eligibility,
            evaluation.exclusion_name,
            evaluation.exclusion,
            evaluation.status,
            evaluation.comments
          ]
        end
      end
      send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                            disposition: "attachment; filename=\"Evaluations #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.csv\""
    end

end
