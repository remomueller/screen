class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_screener_or_subject_handler
  before_action :set_event, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_event, only: [ :show, :edit, :update, :destroy ]

  # GET /events
  # GET /events.json
  def index
    @order = scrub_order(Event, params[:order], 'events.event_time DESC')
    event_scope = Event.current.order(@order)

    if params[:mrn].to_s.split(',').size > 1
      event_scope = event_scope.with_subject_code(params[:mrn].to_s.gsub(/\s/, '').split(','))
    else
      params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
        event_scope = event_scope.with_mrn(term) unless term.blank?
      end
    end

    event_scope = event_scope.with_patient(params[:patient_id]) unless params[:patient_id].blank?
    event_scope = event_scope.subject_code_not_blank unless current_user.screener?

    @events = event_scope.page(params[:page]).per( 40 )
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render action: 'show', status: :created, location: @event }
      else
        format.html { render action: 'new' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_path, notice: 'Event was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

    def set_event
      @event = Event.find_by_id(params[:id])
    end

    def redirect_without_event
      empty_response_or_root_path unless @event
    end

    def event_params
      params.require(:event).permit(
        :patient_id, :class_name, :class_id, :event_time, :name
      )
    end

end
