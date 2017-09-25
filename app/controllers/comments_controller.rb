class CommentsController < ApplicationController
  def edit_codes
    comment = Comment.find(params[:id])
    authorize comment
    comment.map_codes(params[:codes])

    render json: { }    
  end
end