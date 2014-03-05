class ChoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin
  before_action :set_choice, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_choice, only: [ :show, :edit, :update, :destroy ]

  # GET /choices
  # GET /choices.json
  def index
    @order = scrub_order(Choice, params[:order], 'choices.category')
    @choices = Choice.current.search(params[:search]).order(@order).page(params[:page]).per( 40 )
  end

  # GET /choices/1
  # GET /choices/1.json
  def show
  end

  # GET /choices/new
  def new
    @choice = Choice.new
  end

  # GET /choices/1/edit
  def edit
  end

  # POST /choices
  # POST /choices.json
  def create
    @choice = current_user.choices.new(choice_params)

    respond_to do |format|
      if @choice.save
        format.html { redirect_to @choice, notice: 'Choice was successfully created.' }
        format.json { render action: 'show', status: :created, location: @choice }
      else
        format.html { render action: 'new' }
        format.json { render json: @choice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /choices/1
  # PUT /choices/1.json
  def update
    respond_to do |format|
      if @choice.update(choice_params)
        format.html { redirect_to @choice, notice: 'Choice was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @choice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /choices/1
  # DELETE /choices/1.json
  def destroy
    @choice.destroy

    respond_to do |format|
      format.html { redirect_to choices_path, notice: 'Choice was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

    def set_choice
      @choice = Choice.find_by_id(params[:id])
    end

    def redirect_without_choice
      empty_response_or_root_path(choices_path) unless @choice
    end


    def choice_params
      params.require(:choice).permit(
        :category, :name, :description, :color, :included_fields
      )
    end

end
