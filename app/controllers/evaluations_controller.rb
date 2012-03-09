class EvaluationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_screener

  def index
    # current_user.update_attribute :evaluations_per_page, params[:evaluations_per_page].to_i if params[:evaluations_per_page].to_i >= 10 and params[:evaluations_per_page].to_i <= 200
    evaluation_scope = Evaluation.current # current_user.all_viewable_evaluations
    params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
      evaluation_scope = evaluation_scope.with_mrn(term) unless term.blank?
    end

    @order = Evaluation.column_names.collect{|column_name| "evaluations.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "evaluations.id"
    evaluation_scope = evaluation_scope.order(@order)

    @evaluations = evaluation_scope.page(params[:page]).per(20) # (current_user.evaluations_per_page)
  end

  def show
    @evaluation = Evaluation.find(params[:id])
  end

  def new
    @evaluation = Evaluation.new(patient_id: params[:patient_id])
  end

  def edit
    @evaluation = Evaluation.find(params[:id])
  end

  def create
    params[:evaluation][:administration_date] = Date.strptime(params[:evaluation][:administration_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:administration_date].blank?
    params[:evaluation][:expected_receipt_date] = Date.strptime(params[:evaluation][:expected_receipt_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:expected_receipt_date].blank?
    params[:evaluation][:receipt_date] = Date.strptime(params[:evaluation][:receipt_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:receipt_date].blank?
    params[:evaluation][:storage_date] = Date.strptime(params[:evaluation][:storage_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:storage_date].blank?
    params[:evaluation][:reimbursement_form_date] = Date.strptime(params[:evaluation][:reimbursement_form_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:reimbursement_form_date].blank?
    params[:evaluation][:scored_date] = Date.strptime(params[:evaluation][:scored_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:scored_date].blank?

    @evaluation = Evaluation.new(params[:evaluation])

    if @evaluation.save
      redirect_to @evaluation.patient, notice: 'Evaluation was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    params[:evaluation][:administration_date] = Date.strptime(params[:evaluation][:administration_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:administration_date].blank?
    params[:evaluation][:expected_receipt_date] = Date.strptime(params[:evaluation][:expected_receipt_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:expected_receipt_date].blank?
    params[:evaluation][:receipt_date] = Date.strptime(params[:evaluation][:receipt_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:receipt_date].blank?
    params[:evaluation][:storage_date] = Date.strptime(params[:evaluation][:storage_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:storage_date].blank?
    params[:evaluation][:reimbursement_form_date] = Date.strptime(params[:evaluation][:reimbursement_form_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:reimbursement_form_date].blank?
    params[:evaluation][:scored_date] = Date.strptime(params[:evaluation][:scored_date], "%m/%d/%Y") if params[:evaluation] and not params[:evaluation][:scored_date].blank?

    @evaluation = Evaluation.find(params[:id])

    if @evaluation.update_attributes(params[:evaluation])
      redirect_to @evaluation, notice: 'Evaluation was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @evaluation = Evaluation.find(params[:id])
    @evaluation.destroy

    redirect_to evaluations_path
  end
end
