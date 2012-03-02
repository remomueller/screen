class MailingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_screener

  def index
    # current_user.update_attribute :mailings_per_page, params[:mailings_per_page].to_i if params[:mailings_per_page].to_i >= 10 and params[:mailings_per_page].to_i <= 200
    mailing_scope = Mailing.current # current_user.all_viewable_mailings
    params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
      mailing_scope = mailing_scope.with_mrn(term) unless term.blank?
    end

    @order = Mailing.column_names.collect{|column_name| "mailings.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "mailings.id"
    mailing_scope = mailing_scope.order(@order)

    @mailings = mailing_scope.page(params[:page]).per(20) # (current_user.mailings_per_page)
  end

  def show
    @mailing = Mailing.find(params[:id])
  end

  def new
    @mailing = Mailing.new(patient_id: params[:patient_id])
  end

  def edit
    @mailing = Mailing.find(params[:id])
  end

  def create
    params[:mailing][:sent_date] = Date.strptime(params[:mailing][:sent_date], "%m/%d/%Y") if params[:mailing] and not params[:mailing][:sent_date].blank?
    params[:mailing][:response_date] = Date.strptime(params[:mailing][:response_date], "%m/%d/%Y") if params[:mailing] and not params[:mailing][:response_date].blank?

    @mailing = Mailing.new(params[:mailing])

    if @mailing.save
      redirect_to @mailing.patient, notice: 'Mailing was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    params[:mailing][:sent_date] = Date.strptime(params[:mailing][:sent_date], "%m/%d/%Y") if params[:mailing] and not params[:mailing][:sent_date].blank?
    params[:mailing][:response_date] = Date.strptime(params[:mailing][:response_date], "%m/%d/%Y") if params[:mailing] and not params[:mailing][:response_date].blank?

    @mailing = Mailing.find(params[:id])

    if @mailing.update_attributes(params[:mailing])
      redirect_to @mailing, notice: 'Mailing was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @mailing = Mailing.find(params[:id])
    @mailing.destroy

    redirect_to mailings_path
  end
end
