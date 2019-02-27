class ListeningController < ApplicationController
  def index
    authorize(:listening, :index?)
  end
end