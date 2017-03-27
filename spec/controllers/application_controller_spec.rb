require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  # REF: https://www.relishapp.com/rspec/rspec-rails/docs/controller-specs/anonymous-controller
  controller(ApplicationController) do
    def hello
      render :nothing => true
    end
  end
  
  before do
    routes.draw do
      get 'hello' => 'anonymous#hello'
    end
  end
  
  it 'sets the time zone to Pacific before every action' do
    get :hello

    expect(Time.zone).to eq(ActiveSupport::TimeZone["America/Los_Angeles"])
  end
end
