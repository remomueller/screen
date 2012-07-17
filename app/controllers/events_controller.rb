class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_screener_or_subject_handler

  def index
    # current_user.update_attribute :events_per_page, params[:events_per_page].to_i if params[:events_per_page].to_i >= 10 and params[:events_per_page].to_i <= 200
    event_scope = Event.current # current_user.all_viewable_events
    params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
      event_scope = event_scope.with_mrn(term) unless term.blank?
    end

    event_scope = event_scope.with_patient(params[:patient_id]) unless params[:patient_id].blank?
    event_scope = event_scope.subject_code_not_blank unless current_user.screener?

    @order = Event.column_names.collect{|column_name| "events.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "events.event_time DESC"
    event_scope = event_scope.order(@order)

    @events = event_scope.page(params[:page]).per(20) # (current_user.events_per_page)
  end


  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def edit
    @event = Event.find(params[:id])
  end

  def create
    @event = Event.new(post_params)

    if @event.save
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @event = Event.find(params[:id])

    if @event.update_attributes(post_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    redirect_to events_path, notice: 'Event was successfully deleted.'
  end

  private

  def post_params
    params[:event] ||= {}

    params[:event].slice(
      :patient_id, :class_name, :class_id, :event_time, :name
    )
  end

end
