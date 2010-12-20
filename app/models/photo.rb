class Photo < ActiveRecord::Base
  # See http://weblog.techno-weenie.net/articles/acts_as_attachment for more information
  belongs_to :memory
  belongs_to :user
  belongs_to :comment
  acts_as_attachment :storage => :file_system, :max_size => 300.kilobytes, :content_type => :image, :thumbnails => { :normal => '200>', :thumb => '75x75', :avatar => '50x50' }

  validates_as_attachment
end
