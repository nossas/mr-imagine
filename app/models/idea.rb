class Idea < ActiveRecord::Base
  belongs_to :site
  belongs_to :user
  belongs_to :category
  belongs_to :template
  belongs_to :parent, :class_name => 'Idea', :foreign_key => :parent_id
  validates_presence_of :site, :user, :category, :template, :title, :headline
  validates_length_of :headline, :maximum => 140
  scope :featured, where(:featured => true).order('"order"')
  scope :not_featured, where(:featured => false).order("created_at DESC")
  scope :popular, order("likes DESC")
  scope :popular_home, order("likes DESC").limit(4)
  scope :not_popular_home, order("likes DESC").offset(4)
  scope :recommended, where(:recommended => true).order("created_at DESC")
  scope :recent, order("created_at DESC")
end