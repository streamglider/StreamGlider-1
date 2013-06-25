class DefaultStreamsController < ApplicationController
  
  before_filter :authenticate_admin!, :except => [:index, :upload]
  
  # GET /default_streams
  # GET /default_streams.json
  def index
    @streams = Stream.where(:user_id => -1).order('position ASC')

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @streams }
    end
  end

  # GET /default_streams/1
  def show
    @stream = Stream.find(params[:id])
  end

  # GET /default_streams/new
  # GET /default_streams/new.xml
  def new
    @stream = Stream.new
  end

  # GET /default_streams/1/edit
  def edit
    @stream = Stream.find(params[:id])
  end

  # POST /default_streams
  def create
    @stream = Stream.new(params[:stream])
    @stream.user_id = -1

    if @stream.save
      redirect_to default_stream_path(@stream), :notice => 'Default stream was successfully created.'
    else
      render :action => "new"
    end
  end

  # PUT /default_streams/1
  def update
    @stream = Stream.find(params[:id])

    if @stream.update_attributes(params[:stream])
      redirect_to default_stream_path(@stream), :notice => 'Default stream was successfully updated.'
    else
      render :action => "edit"
    end
  end

  # DELETE /default_streams/1
  def destroy
    @stream = Stream.find(params[:id])
    @stream.destroy

    redirect_to(default_streams_url)
  end
  
  def move_up
    @stream = Stream.find(params[:id])
    @stream.move_higher
    
    redirect_to default_streams_url    
  end

  def move_down
    @stream = Stream.find(params[:id])
    @stream.move_lower
    
    redirect_to default_streams_url    
  end
  
  # POST /default_streams/upload.json
  def upload
    
    email = params[:email]
    pwd = params[:password]

    if !email || !pwd
      render_json_error('Default stream upload failed, please provide email and password.')
      return
    end
            
    admin = Admin.first :conditions => { :email => email }
    
    if !admin || !admin.valid_password?(pwd) 
      render_json_error('Default stream upload failed, access denied.')
      return      
    end
    
    s = params[:stream]
    stream_feeds = s[:stream_feeds]

    s.delete 'stream_feeds'

    stream = Stream.new s
    stream.user_id = -1
    
    if stream.save
      # save stream feeds as well
      stream_feeds.each do |sf|
        stream_feed = StreamFeed.new sf
        stream.stream_feeds << stream_feed
      end
      
      render :json => { :status => 'OK' }
    else
      render_json_error('Default stream upload failed.')
    end

  rescue
    render_json_error('this error')     
  end
    
end
