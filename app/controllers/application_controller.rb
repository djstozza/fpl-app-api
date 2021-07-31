# frozen_string_literal: true
require 'application_responder'

class ApplicationController < ActionController::API
  self.responder = ApplicationResponder

  before_action :process_token

  respond_to :json

  include ::ResourceLoading
  include ErrorSerialization

  private

  def respond_with(resource, **meta)
    if resource.respond_to?(:errors) && resource.errors.present?
      render json: serialized_errors(resource), status: meta[:status] || :unprocessable_entity
    else
      render json: { meta: meta, data: resource }
    end
  end

  # Check for auth headers - if present, decode or send unauthorized response (called always to allow current_user)
  def process_token
    service = Auth::ProcessToken.call(request)

    return respond_with service, status: :unauthorized if service.errors.any?

    @current_user_id = service.current_user_id
  end

  # If user has not signed in, return unauthorized response (called only when auth is needed)
  def authenticate_user!(options = {})
    head :unauthorized unless signed_in?
  end

  # set Devise's current_user using decoded JWT instead of session
  def current_user
    @current_user ||= super || User.find(@current_user_id)
  end

  # check that authenticate_user has successfully returned @current_user_id (user is authenticated)
  def signed_in?
    @current_user_id.present?
  end

  def sort_query
    SqlQuery.lit(sort_params.to_h.map { |k, v| "#{k} #{v}" }.join(', '))
  end

  def total_query(subquery)
    SqlQuery.load('count', subquery: subquery).get(:count)
  end
end
