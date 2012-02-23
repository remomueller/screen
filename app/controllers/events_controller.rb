class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin

  # def index
  #   @events = Event.all

  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.json { render json: @events }
  #   end
  # end

  def index
    # current_user.update_attribute :events_per_page, params[:events_per_page].to_i if params[:events_per_page].to_i >= 10 and params[:events_per_page].to_i <= 200
    event_scope = Event.current # current_user.all_viewable_events
    event_scope = event_scope.with_mrn(params[:mrn]) unless params[:mrn].blank?

    @order = Event.column_names.collect{|column_name| "events.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "events.id"
    event_scope = event_scope.order(@order)

    @events = event_scope.page(params[:page]).per(20) # (current_user.events_per_page)
  end


  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end
end
