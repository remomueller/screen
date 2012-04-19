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

    @administration_after = begin Date.strptime(params[:administration_after], "%m/%d/%Y") rescue nil end
    @administration_before = begin Date.strptime(params[:administration_before], "%m/%d/%Y") rescue nil end

    evaluation_scope = evaluation_scope.administration_before(@administration_before) unless @administration_before.blank?
    evaluation_scope = evaluation_scope.administration_after(@administration_after) unless @administration_after.blank?

    @order = Evaluation.column_names.collect{|column_name| "evaluations.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "evaluations.patient_id"
    evaluation_scope = evaluation_scope.order(@order)

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
    params[:evaluation] ||= {}
    [:administration_date, :expected_receipt_date, :receipt_date, :storage_date, :reimbursement_form_date, :scored_date].each do |date|
      params[:evaluation][date] = parse_date(params[:evaluation][date])
    end

    # params[:evaluation][:administration_date] = Date.strptime(params[:evaluation][:administration_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:administration_date].blank?
    # params[:evaluation][:expected_receipt_date] = Date.strptime(params[:evaluation][:expected_receipt_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:expected_receipt_date].blank?
    # params[:evaluation][:receipt_date] = Date.strptime(params[:evaluation][:receipt_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:receipt_date].blank?
    # params[:evaluation][:storage_date] = Date.strptime(params[:evaluation][:storage_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:storage_date].blank?
    # params[:evaluation][:reimbursement_form_date] = Date.strptime(params[:evaluation][:reimbursement_form_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:reimbursement_form_date].blank?
    # params[:evaluation][:scored_date] = Date.strptime(params[:evaluation][:scored_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:scored_date].blank?

    @evaluation = current_user.evaluations.new(params[:evaluation])

    if @evaluation.save
      redirect_to @evaluation.patient, notice: 'Evaluation was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    params[:evaluation] ||= {}
    [:administration_date, :expected_receipt_date, :receipt_date, :storage_date, :reimbursement_form_date, :scored_date].each do |date|
      params[:evaluation][date] = parse_date(params[:evaluation][date])
    end

    # params[:evaluation][:administration_date] = Date.strptime(params[:evaluation][:administration_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:administration_date].blank?
    # params[:evaluation][:expected_receipt_date] = Date.strptime(params[:evaluation][:expected_receipt_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:expected_receipt_date].blank?
    # params[:evaluation][:receipt_date] = Date.strptime(params[:evaluation][:receipt_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:receipt_date].blank?
    # params[:evaluation][:storage_date] = Date.strptime(params[:evaluation][:storage_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:storage_date].blank?
    # params[:evaluation][:reimbursement_form_date] = Date.strptime(params[:evaluation][:reimbursement_form_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:reimbursement_form_date].blank?
    # params[:evaluation][:scored_date] = Date.strptime(params[:evaluation][:scored_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:scored_date].blank?

    @evaluation = Evaluation.find_by_id(params[:id])

    if @evaluation and @evaluation.patient.editable_by?(current_user)
      if @evaluation.update_attributes(params[:evaluation])
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
      redirect_to evaluations_path
    else
      redirect_to root_path
    end
  end
end
