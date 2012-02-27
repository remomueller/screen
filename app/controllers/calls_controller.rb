class CallsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin

  def index
    # current_user.update_attribute :calls_per_page, params[:calls_per_page].to_i if params[:calls_per_page].to_i >= 10 and params[:calls_per_page].to_i <= 200
    call_scope = Call.current # current_user.all_viewable_calls
    params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
      call_scope = call_scope.with_mrn(term) unless term.blank?
    end

    @order = Call.column_names.collect{|column_name| "calls.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "calls.id"
    call_scope = call_scope.order(@order)

    @calls = call_scope.page(params[:page]).per(20) # (current_user.calls_per_page)
  end

  def show
    @call = Call.find(params[:id])
  end

  def new
    @call = Call.new(patient_id: params[:patient_id])
  end

  def edit
    @call = Call.find(params[:id])
  end

  def create
    @call = Call.new(params[:call])

    if @call.save
      redirect_to @call, notice: 'Call was successfully created.'
    else
      render action: "new"
    end
  end

  # PUT /calls/1
  # PUT /calls/1.json
  def update
    @call = Call.find(params[:id])

    respond_to do |format|
      if @call.update_attributes(params[:call])
        format.html { redirect_to @call, notice: 'Call was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @call.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /calls/1
  # DELETE /calls/1.json
  def destroy
    @call = Call.find(params[:id])
    @call.destroy

    respond_to do |format|
      format.html { redirect_to calls_url }
      format.json { head :no_content }
    end
  end
end
