class PlansController < ApplicationController

  def index
    year = params[:year] || Time.now.year
    synced_date = params[:synced_timestamp] ? Time.at(params[:synced_timestamp].to_i) : nil
    options = {
      :include => {
        :counts => true
      }
    }

    response = {
      :plans => Plan.synced_models(synced_date, nil, Plan.count, { :year => year }).as_json(options)
    }
    render :json => response
  end
end
