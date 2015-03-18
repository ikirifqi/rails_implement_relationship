class Comment < ActiveRecord::Base
  belongs_to :article

  validates :body, :article_id, :presence => true
end
