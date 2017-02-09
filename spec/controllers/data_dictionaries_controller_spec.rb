require 'rails_helper'

RSpec.describe DataDictionariesController, type: :controller do
  before do
    sign_in create(:administrator)
  end

  describe 'GET #show' do
    before do
      @data_dictionary = create(:data_dictionary)
      get :show, id: @data_dictionary
    end
    
    it 'assigns the requested data dictionary to @data_dictionary' do
      expect(assigns(:data_dictionary)).to eq(@data_dictionary)
    end
    
    it 'uses the workspace layout' do
      expect(response).to render_template :workspace
    end
    
    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :show, id: @data_dictionary

      expect(response).to redirect_to :new_user_session
    end
  end
  
  describe 'GET #edit' do
    before do
      @data_dictionary = create(:data_dictionary)
      get :edit, id: @data_dictionary
    end

    it 'assigns the requested data dictionary to @data_dictionary' do
      expect(assigns(:data_dictionary)).to eq(@data_dictionary)
    end

    it 'renders the edit template' do
      expect(response).to render_template :edit
    end

    it 'uses the workspace layout' do
      expect(response).to render_template :workspace
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :edit, id: @data_dictionary

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'PATCH update' do
    before do
      experiment = create(:experiment)
      DataDictionary.create_data_dictionary(experiment)
      
      @data_dictionary = create(:data_dictionary)
      @data_dictionary.data_dictionary_entries << create(:data_dictionary_entry, data_dictionary: @data_dictionary)
      
      patch :update, id: @data_dictionary, data_dictionary: attributes_for(:data_dictionary, data_dictionary_entries_attributes: { "0" => { "include_in_report" => "1", "report_label" => "new_report_label", "value_mapping" => "{ 'new_value' => 'new_mapping' }", "note" => "New note", "id" => "#{@data_dictionary.data_dictionary_entries[0].id}" } })
    end
    
    context 'with valid attributes' do
      it 'assigns the requested data dictionary to @data_dictionary' do
        expect(assigns(:data_dictionary)).to eq(@data_dictionary)
      end

      it "changes the attributes of the data dictionary entries" do
        @data_dictionary.reload
        data_dictionary_entry = @data_dictionary.data_dictionary_entries[0]
        data_dictionary_entry.reload
        
        # expect(data_dictionary_entry.include_in_report).to be true
        expect(data_dictionary_entry.report_label).to eq('new_report_label')
        expect(data_dictionary_entry.value_mapping).to eq("{ 'new_value' => 'new_mapping' }")
        expect(data_dictionary_entry.note).to eq('New note')
      end

      it 'redirects to the show page' do
        expect(response).to redirect_to data_dictionary_url(@data_dictionary)
      end
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      patch :update, id: @data_dictionary

      expect(response).to redirect_to :new_user_session
    end
  end
end