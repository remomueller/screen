class PrescreensController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin

  def inline_update
    @prescreen = Prescreen.find_by_id(params[:id])
    item = Prescreen::EDITABLES.include?(params[:item]) ? params[:item].to_sym : ''
    @prescreen.update_attribute(item, params[:update_value]) if @prescreen and not item.blank?
  end

  def bulk
    new_count = Prescreen.process_bulk(params)
    redirect_to prescreens_path, notice: "#{new_count} Prescreen#{'s' unless new_count == 1} added!"
  end

  # GET /prescreens
  # GET /prescreens.json
  def index
    @prescreens = Prescreen.current.order(:cardiologist, :visit_at)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @prescreens }
    end
  end

  # GET /prescreens/1
  # GET /prescreens/1.json
  def show
    @prescreen = Prescreen.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @prescreen }
    end
  end

  # GET /prescreens/new
  # GET /prescreens/new.json
  def new
    @prescreen = Prescreen.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @prescreen }
    end
  end

  # GET /prescreens/1/edit
  def edit
    @prescreen = Prescreen.find(params[:id])
  end

  # POST /prescreens
  # POST /prescreens.json
  def create
    @prescreen = Prescreen.new(params[:prescreen])

    respond_to do |format|
      if @prescreen.save
        format.html { redirect_to @prescreen, notice: 'Prescreen was successfully created.' }
        format.json { render json: @prescreen, status: :created, location: @prescreen }
      else
        format.html { render action: "new" }
        format.json { render json: @prescreen.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /prescreens/1
  # PUT /prescreens/1.json
  def update
    @prescreen = Prescreen.find(params[:id])

    respond_to do |format|
      if @prescreen.update_attributes(params[:prescreen])
        format.html { redirect_to @prescreen, notice: 'Prescreen was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @prescreen.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /prescreens/1
  # DELETE /prescreens/1.json
  def destroy
    @prescreen = Prescreen.find(params[:id])
    @prescreen.destroy

    respond_to do |format|
      format.html { redirect_to prescreens_url }
      format.json { head :no_content }
    end
  end
end
