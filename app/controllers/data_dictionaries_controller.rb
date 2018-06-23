class DataDictionariesController < ApplicationController
  before_action :set_data_dictionary, only: [:show, :edit, :update]
  layout "workspace", only: [:show, :edit]

  def show
    authorize @data_dictionary
  end

  def edit
  end
  
  def update
    if @data_dictionary.update(data_dictionary_params)
      redirect_to data_dictionary_url(@data_dictionary)
    else
      render :edit
    end
  end

  private

  def set_data_dictionary
    @data_dictionary = DataDictionary.find(params[:id])
    authorize @data_dictionary
  end

  def data_dictionary_params
    # TODO: Unit test this
    params.require(:data_dictionary).permit(data_dictionary_entries_attributes: [:id, :include_in_report, :report_label, :allowed_values, :value_mapping, :note])
  end
end