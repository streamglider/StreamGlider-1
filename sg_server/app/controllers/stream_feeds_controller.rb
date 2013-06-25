class StreamFeedsController < ApplicationController
  
  before_filter :authenticate_admin!
  
  # GET /feeds/new
  # GET /feeds/new.xml
  def new
    @stream_feed = StreamFeed.new
    
    stream_id = params[:stream_id]
        
    unless stream_id
      render_error
      return
    end
    
    @stream_feed.stream = Stream.find params[:stream_id]
  rescue
    render_error  
  end
  
  # GET /feeds/1/edit
  def edit
    @stream_feed = StreamFeed.find(params[:id])
  end
  

  # POST /stream_feeds
  def create    
    @stream_feed = StreamFeed.new(params[:stream_feed])
            
    if @stream_feed.save
      redirect_to default_stream_url(@stream_feed.stream), :notice => 'Feed was created successfully.'
    else
      render :action => "new"
    end
    
  rescue
    render_json_error  
  end

  # PUT /stream_feeds/1
  def update
    @stream_feed = StreamFeed.find(params[:id])
    
    if @stream_feed.update_attributes(params[:stream_feed])
      redirect_to default_stream_url(@stream_feed.stream), :notice => 'Feed was updated successfully.'
    else
      render :action => "edit"
    end
    
  rescue
    render_json_error  
  end

  # DELETE /stream_feeds/1
  def destroy
    @stream_feed = StreamFeed.find(params[:id])    
    stream = @stream_feed.stream
    @stream_feed.destroy
    redirect_to default_stream_url(stream), :notice => 'Feed was removed successfully.'
  rescue
    render_json_error  
  end
  
  def move_up
    @stream_feed = StreamFeed.find(params[:id])
    @stream_feed.move_higher
    
    redirect_to default_stream_url(@stream_feed.stream)    
  end

  def move_down
    @stream_feed = StreamFeed.find(params[:id])
    @stream_feed.move_lower
    
    redirect_to default_stream_url(@stream_feed.stream)
  end
  
end
