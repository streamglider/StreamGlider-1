class StreamsController < ApplicationController
  
  before_filter :authenticate_user!
  
  # GET /streams.json
  def index    
    @streams = Stream.where :user_id => current_user.id    
    render :json => @streams    
  end

  # GET /streams/1.json
  def show
    @stream = Stream.find(params[:id])
    
    st = current_user.incoming_streams.where :stream_id => @stream.id
    if @stream.user != current_user && !st
      render_json_error
      return      
    end
    
    render :json => @stream    
  rescue
    render_json_error  
  end

  # POST /streams.json
  def create
    @stream = Stream.new(params[:stream])
    @stream.user = current_user
    
    if @stream.save
      render :json => { :status => "OK", :stream_id => @stream.id }
    else
      render :json => { :error => "stream was not saved" }
    end
  end

  # PUT /streams/1.json
  def update
    @stream = Stream.find(params[:id])
    
    unless @stream.user == current_user
      render_json_error
      return      
    end
    
    pos = params[:stream][:position]
    unless pos == @stream.position
      @stream.insert_at pos
    end

    if @stream.update_attributes(params[:stream])
      render :json => { :status => "OK" }
    else
      render :json => { :error => "stream was not updated" }
    end
    
  rescue
    render_json_error  
  end

  # DELETE /streams/1.json
  def destroy
    @stream = Stream.find(params[:id])
    
    unless @stream.user == current_user
      render_json_error
      return      
    end
    
    @stream.destroy
    render :json => { :status => "OK" }
  rescue
    render_json_error  
  end
  
  #POST /share_streams.json
  def share_stream
    email = params[:email]
    
    unless email
      render_json_error('Please provide an email.')
      return
    end
    
    user = User.find_by_email(email) 
    
    unless user
      render_json_error('User with provided email was not found.') 
      return
    end
    
    s = params[:stream]
    stream_feeds = s[:stream_feeds]
    
    s.delete 'stream_feeds'
    
    stream = Stream.new s
    stream.user = current_user
    if stream.save
      # save stream feeds as well
      stream_feeds.each do |sf|
        stream_feed = StreamFeed.new sf
        stream.stream_feeds << stream_feed
      end
      
      # create a share_to object
      share = ShareTo.new :stream => stream, :user => user
      share.save!
      
      render :json => { :status => 'OK' }
    else
      render_json_error('Stream upload failed.')
    end
    
  rescue
    render_json_error 
  end
  
end
