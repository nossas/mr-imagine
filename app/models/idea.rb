class Idea < ActiveRecord::Base
  
  include Rails.application.routes.url_helpers
  include AutoHtml
  
  belongs_to :user
  belongs_to :category
  belongs_to :parent, :class_name => 'Idea', :foreign_key => :parent_id
  has_many :versions, :class_name => 'Idea', :foreign_key => :parent_id
  has_many :merges
  validates_presence_of :user, :category, :title, :headline
  validates_length_of :headline, :maximum => 140

  scope :featured, where(:featured => true).order('created_at DESC')
  scope :not_featured, where(:featured => false)
  scope :recommended, where(:recommended => true).order("created_at DESC")
  scope :popular, order("likes DESC")
  scope :recent, order("created_at DESC")
  
  scope :primary, where("parent_id IS NULL")
  scope :secondary, where("parent_id IS NOT NULL")

  attr_accessor :was_new_record
  attr_accessor :forking
  attr_accessor :merging
  attr_accessor :without_save_document
  
  before_save :set_was_new_record
  def set_was_new_record
    self.was_new_record = new_record?
    return true
  end

  def doc_cache_name
    "document_cache_#{self.id}.json"
  end

  def expire_doc_cache
    Rails.cache.delete(doc_cache_name)
    Rails.cache.delete("merges_needed_#{self.id}")
  end

  after_save :save_document
  def save_document
    return if self.without_save_document == true
    begin
      self.expire_doc_cache
      if self.forking
        self.document = JSON.parse(RestClient.post("#{self.url}/#{self.parent.id}/fork/#{self.id}", ""))
      elsif self.was_new_record
        RestClient.post "#{self.url}", document.to_json
      elsif not self.merging
        RestClient.put "#{self.url}/#{self.id}", document.to_json
      end
      Rails.cache.write(doc_cache_name, document.to_json)
    rescue Exception => e
      Rails.logger.error "Failed to save document from idea ##{self.id}: #{e.message}"
    end
  end

  after_find :load_document
  def load_document
    begin
      self.document = JSON.parse(Rails.cache.fetch(doc_cache_name) {
        RestClient.get("#{self.url}/#{self.id}")
      })
    rescue Exception => e
      Rails.logger.error "Failed to load the document from idea ##{self.id}: #{e.message}"
    end
  end

  before_destroy :remove_dependencies
  def remove_dependencies
    self.merges.each {|merge| merge.destroy } if self.merges.size > 0
    self.versions.each {|version| version.parent = nil; version.save } if self.versions.size > 0
    Merge.merges_from(self.id).each {|m| m.destroy}
  end

  after_destroy :delete_document
  def delete_document
    # self.expire_doc_cache
    begin
      RestClient.delete "#{self.url}/#{self.id}"
    rescue Exception => e
      Rails.logger.error "Failed to delete the document from idea ##{self.id}: #{e.message}"
    end
  end
  
  def create_fork(current_user)
    fork = Idea.new({
      :parent => self,
      :user => current_user,
      :category => self.category,
      :title => self.title,
      :headline => self.headline
    })
    fork.forking = true
    if fork.save
      fork
    else
      nil
    end
  end
  
  def merge!(from_id)
    self.merging = true
    self.merges.merges_from(from_id).pending.update_all :pending => false
    merge = self.merges.new :from_id => from_id
    begin
      merged_document = JSON.parse(RestClient.put("#{self.url}/#{self.id}/merge/#{from_id}", { :user_id => self.user.id }.to_json))
      self.title = merged_document["title"]
      self.headline = merged_document["headline"]
      self.save
      self.document = merged_document
      merge.finished = true
    rescue
      merge.pending = true
    end
    self.merging = false
    merge.save
    merge.finished
  end
  
  def conflicts(from_id)
    begin
      @conflicts ||= JSON.parse(RestClient.get("#{self.url}/#{self.id}/pending_merges"))
      return unless @conflicts.is_a?(Array)
      @conflicts.each do |conflict|
        return conflict if conflict["from_id"] and conflict["from_id"].to_s == from_id.to_s
      end
    rescue
    end
  end

  def resolve_conflicts!(from_id, conflict_attributes)
    merge = self.merges.merges_from(from_id).pending.first
    return unless merge
    self.merging = true
    begin
      merged_document = JSON.parse(RestClient.put("#{self.url}/#{self.id}/resolve_conflicts/#{from_id}", conflict_attributes.merge({ :user_id => self.user.id }).to_json))
      self.title = merged_document["title"]
      self.headline = merged_document["headline"]
      self.save
      self.document = merged_document
      merge.pending = false
      merge.finished = true
    rescue
      merge.pending = true
    end
    self.merging = false
    merge.save
    merge.finished
  end

  def self.url
    @@url ||= Configuration.find_by_name('git_document_db_url').value
  rescue
    nil
  end
  def url
    self.class.url
  end
  
  def document
    @document ||= {}
    @document.merge! "id" => self.id, "user_id" => self.user_id, "title" => self.title, "headline" => self.headline
  end
  
  def document=(new_document)
    @document = new_document.merge "id" => self.id, "user_id" => self.user_id, "title" => self.title, "headline" => self.headline
  end
  
  def description
    document["description"]
  end
  
  def description=(value)
    document["description"] = value
  end
  
  def description_html
    convert_html description
  end
  
  def convert_html(text)
    auto_html text do
      html_escape :map => { 
        '&' => '&amp;',  
        '>' => '&gt;',
        '<' => '&lt;',
        '"' => '"' }
      redcloth :target => :_blank
      image
      youtube :width => 510, :height => 332
      vimeo :width => 510, :height => 332
      link :target => :_blank
    end
  end
  
  def to_param
    "#{self.id}-#{self.title.parameterize}"
  end

  def as_json(options={})
    {
      :id => id,
      :title => title,
      :headline => headline,
      :category => category,
      :user => user,
      :description => description,
      :description_html => description_html,
      :likes => likes,
      :versions_count => versions.count,
      :document => document,
      :url => idea_path(self)
    }
  end
  
  def need_to_merge?
    return @need_to_merge if @need_to_merge
    merge_needed?(self, parent)
  end
  
  def parent_need_to_merge?
    return @parent_need_to_merge if @parent_need_to_merge
    merge_needed?(parent, self)
  end
  
  def pending_merge(from)
    self.merges.merges_from(from).pending.first
  end
    
  private
  
  def merge_needed?(idea = nil, from = nil)
    return false unless parent
    idea = self unless idea
    from = parent unless from
    begin
      Rails.cache.fetch("merges_needed_#{self.id}_from_#{from.id}", :expires_in => 30.minutes) {
        RestClient.get("#{self.url}/#{idea.id}/merge_needed/#{from.id}") == "true"
      }
    rescue
      false
    end
  end
end
