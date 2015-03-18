class CommentsController < ApplicationController
  before_action :set_article, only: [:create]
  before_action :set_comment, only: [:destroy]

  # POST /articles/1/comments
  # POST /articles/1/comments.json
  def create
    @comment = @article.comments.build(comment_params)

    respond_to do |format|
      if @comment.save
        format.html { redirect_to :back, notice: 'Comment was successfully created.' }
      else
        format.html { redirect_to :back, notice: 'Failed to create comment.' }
      end
    end
  end

  # DELETE /articles/1/comments/1
  # DELETE /articles/1/comments/1.json
  def destroy
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to :back, notice: 'Comment was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def set_article
      @article = Article.find(params[:article_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:body)
    end
end
