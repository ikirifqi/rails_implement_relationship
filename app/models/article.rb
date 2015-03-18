class Article < ActiveRecord::Base
  paginates_per 10

  has_many :comments, :dependent => :destroy

  validates :title, :body, :presence => true
end
