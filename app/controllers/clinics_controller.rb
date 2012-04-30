class ClinicsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_screener

  def index
    # current_user.update_attribute :clinics_per_page, params[:clinics_per_page].to_i if params[:clinics_per_page].to_i >= 10 and params[:clinics_per_page].to_i <= 200
    clinic_scope = Clinic.current # current_user.all_viewable_clinics
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| clinic_scope = clinic_scope.search(search_term) }

    @order = Clinic.column_names.collect{|column_name| "clinics.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "clinics.name"
    clinic_scope = clinic_scope.order(@order)

    @clinic_count = clinic_scope.count
    @clinics = clinic_scope.page(params[:page]).per(40) # (current_user.clinics_per_page)
  end

  # GET /clinics/1
  # GET /clinics/1.json
  def show
    @clinic = Clinic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @clinic }
    end
  end

  # GET /clinics/new
  # GET /clinics/new.json
  def new
    @clinic = Clinic.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @clinic }
    end
  end

  # GET /clinics/1/edit
  def edit
    @clinic = Clinic.find(params[:id])
  end

  # POST /clinics
  # POST /clinics.json
  def create
    @clinic = current_user.clinics.new(params[:clinic])

    respond_to do |format|
      if @clinic.save
        format.html { redirect_to @clinic, notice: 'Clinic was successfully created.' }
        format.json { render json: @clinic, status: :created, location: @clinic }
      else
        format.html { render action: "new" }
        format.json { render json: @clinic.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @clinic = Clinic.find(params[:id])

    if @clinic.update_attributes(params[:clinic])
      notice = 'Clinic was successfully updated.'
      if params[:from] == 'prescreens'
        redirect_to prescreens_path, notice: notice
      else
        redirect_to @clinic, notice: notice
      end
    else
      render action: "edit"
    end
  end

  def destroy
    @clinic = Clinic.find(params[:id])
    @clinic.destroy

    redirect_to clinics_path, notice: 'Clinic was successfully deleted.'
  end
end
