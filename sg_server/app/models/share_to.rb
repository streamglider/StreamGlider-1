class ShareTo < ActiveRecord::Base
  belongs_to :user
  belongs_to :stream
  
  validates :user, :stream, :presence => true
  
  def as_json(options)
    if stream.user != nil
      { :stream_id => stream.id, :share_to_id => self.id, :title => stream.title, :email => stream.user.email }
    else   
      { :stream_id => stream.id, :share_to_id => self.id, :title => stream.title, :email => 'Email Unknown' }
    end  
  end
  
end