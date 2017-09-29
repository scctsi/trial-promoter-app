class CommentsController < ApplicationController
  def edit_codes
    comment = Comment.find(params[:id])
    authorize comment
    comment.code_list = (params[:codes])
    comment.save
    
    render json: { }    
  end
end