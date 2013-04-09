class ChoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin

  def index
    # current_user.update_column :choices_per_page, params[:choices_per_page].to_i if params[:choices_per_page].to_i >= 10 and params[:choices_per_page].to_i <= 200
    choice_scope = Choice.current # current_user.all_viewable_choices
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| choice_scope = choice_scope.search(search_term) }

    @order = scrub_order(Choice, params[:order], 'choices.category')
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
    @choice = current_user.choices.new(post_params)

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
      if @choice.update_attributes(post_params)
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

    redirect_to choices_path, notice: 'Choice was successfully deleted.'
  end

  private

  def post_params
    params[:choice] ||= {}

    params[:choice].slice(
      :category, :name, :description, :color, :included_fields
    )
  end

end
