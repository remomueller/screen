class MailingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin

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


  # GET /mailings/1
  # GET /mailings/1.json
  def show
    @mailing = Mailing.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mailing }
    end
  end

  # GET /mailings/new
  # GET /mailings/new.json
  def new
    @mailing = Mailing.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mailing }
    end
  end

  # GET /mailings/1/edit
  def edit
    @mailing = Mailing.find(params[:id])
  end

  # POST /mailings
  # POST /mailings.json
  def create
    @mailing = Mailing.new(params[:mailing])

    respond_to do |format|
      if @mailing.save
        format.html { redirect_to @mailing, notice: 'Mailing was successfully created.' }
        format.json { render json: @mailing, status: :created, location: @mailing }
      else
        format.html { render action: "new" }
        format.json { render json: @mailing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /mailings/1
  # PUT /mailings/1.json
  def update
    @mailing = Mailing.find(params[:id])

    respond_to do |format|
      if @mailing.update_attributes(params[:mailing])
        format.html { redirect_to @mailing, notice: 'Mailing was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mailing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mailings/1
  # DELETE /mailings/1.json
  def destroy
    @mailing = Mailing.find(params[:id])
    @mailing.destroy

    respond_to do |format|
      format.html { redirect_to mailings_url }
      format.json { head :no_content }
    end
  end
end
