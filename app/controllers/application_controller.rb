# frozen_string_literal: true
require "application_responder"

class ApplicationController < ActionController::API
  self.responder = ApplicationResponder
  respond_to :json

  include ::ResourceLoading

  rescue_from ActiveRecord::RecordInvalid do |exception|
    respond_with exception.record
  end

  private

  def respond_with(resource, **meta)
    if resource.respond_to?(:errors) && resource.errors.present?
      render json: serialized_errors(resource), status: :unprocessable_entity
    else
      render json: { meta: meta, data: resource }
    end
  end
end
