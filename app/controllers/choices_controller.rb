class ChoicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin

  # GET /choices
  # GET /choices.json
  def index
    @choices = Choice.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @choices }
    end
  end

  # GET /choices/1
  # GET /choices/1.json
  def show
    @choice = Choice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @choice }
    end
  end

  # GET /choices/new
  # GET /choices/new.json
  def new
    @choice = Choice.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @choice }
    end
  end

  # GET /choices/1/edit
  def edit
    @choice = Choice.find(params[:id])
  end

  # POST /choices
  # POST /choices.json
  def create
    @choice = Choice.new(params[:choice])

    respond_to do |format|
      if @choice.save
        format.html { redirect_to @choice, notice: 'Choice was successfully created.' }
        format.json { render json: @choice, status: :created, location: @choice }
      else
        format.html { render action: "new" }
        format.json { render json: @choice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /choices/1
  # PUT /choices/1.json
  def update
    @choice = Choice.find(params[:id])

    respond_to do |format|
      if @choice.update_attributes(params[:choice])
        format.html { redirect_to @choice, notice: 'Choice was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @choice.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @choice = Choice.find(params[:id])
    @choice.destroy

    redirect_to choices_path
  end
end
