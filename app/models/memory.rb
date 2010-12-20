class Memory < ActiveRecord::Base
  acts_as_taggable
  belongs_to :user
  has_one :photo
  has_many :comments
  has_and_belongs_to_many :friends

  validates_presence_of :title, :body, :user_id, :year

  def self.list_years( year = Date.today.year, limit = 10 )
    return find_by_sql( ['select distinct(year) from memories where year <= ? group by year order by year asc limit ?', year, limit] )
  end

  def self.nearby( year = Date.today, limit = 3 )
    return find_by_sql( ['select distinct(year) from memories where year < ? group by year order by year desc limit ?', year, limit] ).reverse
  end
end
