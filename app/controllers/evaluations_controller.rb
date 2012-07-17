class EvaluationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_screener_or_subject_handler

  def index
    # current_user.update_attribute :evaluations_per_page, params[:evaluations_per_page].to_i if params[:evaluations_per_page].to_i >= 10 and params[:evaluations_per_page].to_i <= 200
    evaluation_scope = Evaluation.current # current_user.all_viewable_evaluations
    params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
      evaluation_scope = evaluation_scope.with_mrn(term) unless term.blank?
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

    @order = Evaluation.column_names.collect{|column_name| "evaluations.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "evaluations.patient_id"
    evaluation_scope = evaluation_scope.order(@order)

    if params[:format] == 'csv'
      generate_csv(evaluation_scope)
      return
    end

    @evaluation_count = evaluation_scope.count
    @evaluations = evaluation_scope.page(params[:page]).per(20) # (current_user.evaluations_per_page)
  end

  def show
    @evaluation = Evaluation.find_by_id(params[:id])
    redirect_to root_path unless @evaluation and @evaluation.patient.editable_by?(current_user)
  end

  def new
    @evaluation = Evaluation.new(patient_id: params[:patient_id])
    redirect_to root_path unless @evaluation and @evaluation.patient.editable_by?(current_user)
  end

  def edit
    @evaluation = Evaluation.find_by_id(params[:id])
    redirect_to root_path unless @evaluation and @evaluation.patient.editable_by?(current_user)
  end

  def create
    @evaluation = current_user.evaluations.new(post_params)

    if @evaluation.save
      redirect_to @evaluation.patient, notice: 'Evaluation was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @evaluation = Evaluation.find_by_id(params[:id])

    if @evaluation and @evaluation.patient.editable_by?(current_user)
      if @evaluation.update_attributes(post_params)
        redirect_to @evaluation, notice: 'Evaluation was successfully updated.'
      else
        render action: "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @evaluation = Evaluation.find_by_id(params[:id])
    if @evaluation and @evaluation.patient.editable_by?(current_user)
      @evaluation.destroy
      redirect_to evaluations_path, notice: 'Evaluation was successfully deleted.'
    else
      redirect_to root_path
    end
  end

  private

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

  def post_params
    params[:evaluation] ||= {}

    [:administration_date, :expected_receipt_date, :receipt_date, :storage_date, :reimbursement_form_date, :scored_date].each do |date|
      params[:evaluation][date] = parse_date(params[:evaluation][date])
    end

    params[:evaluation].slice(
      :patient_id, :administration_type, :evaluation_type, :administration_date, :source, :embletta_unit_number, :expected_receipt_date, :receipt_date, :storage_date, :subject_notified, :reimbursement_form_date, :scored_date, :ahi, :eligibility, :exclusion, :status, :comments
    )
  end

end
