require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  before do
    sign_in create(:administrator)
  end
  
  describe 'POST #edit_codes' do
    before do
      @comment = create(:comment)  
    end
    
    it 'adds codes to the comment' do
      post :edit_codes, id: @comment.id, codes: ["positive", "negative"]
      
      @comment.reload
      expect(@comment.code_list.count).to eq(2)
      expect(@comment.code_list).to include("positive", "negative")
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      post :edit_codes, id: @comment.id, codes: ["1:color", "2:monochrome"]

      expect(response).to redirect_to :new_user_session
    end
  end
end