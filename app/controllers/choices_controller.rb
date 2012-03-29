class ChoicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin

  def index
    # current_user.update_attribute :choices_per_page, params[:choices_per_page].to_i if params[:choices_per_page].to_i >= 10 and params[:choices_per_page].to_i <= 200
    choice_scope = Choice.current # current_user.all_viewable_choices
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| choice_scope = choice_scope.search(search_term) }

    @order = Choice.column_names.collect{|column_name| "choices.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "choices.category"
    choice_scope = choice_scope.order(@order)

    @choice_count = choice_scope.count
    @choices = choice_scope.page(params[:page]).per(40) # (current_user.choices_per_page)
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
    @choice = current_user.choices.new(params[:choice])

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
