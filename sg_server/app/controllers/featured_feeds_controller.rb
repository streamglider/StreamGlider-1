class FeaturedFeedsController < ApplicationController
  
  before_filter :authenticate_admin!, :except => :index
  
  # GET /featured_feeds
  # GET /featured_feeds.xml
  # GET /featured_feeds.json
  def index
    @featured_feeds = FeaturedFeed.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @featured_feeds }
      format.json { render :json => @featured_feeds }
    end
  end

  # GET /featured_feeds/1
  # GET /featured_feeds/1.xml
  def show
    @featured_feed = FeaturedFeed.find(params[:id])
    
    @parents = []
    cat = @featured_feed.feed
    while true
      if cat.parent
        @parents << cat.parent
        cat = cat.parent
      else
        break
      end
    end
    
    @parents.reverse!

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @featured_feed }
    end
  end

  # GET /featured_feeds/new
  def new
    @featured_feed = FeaturedFeed.new
    @featured_feed.feed = Feed.find params[:feed_id]
  rescue
    render_error  
  end

  # GET /featured_feeds/1/edit
  def edit
    @featured_feed = FeaturedFeed.find(params[:id])
  end

  # POST /featured_feeds
  # POST /featured_feeds.xml
  def create
    @featured_feed = FeaturedFeed.new(params[:featured_feed])
    @featured_feed.position = FeaturedFeed.count + 1
    respond_to do |format|
      if @featured_feed.save
        format.html { redirect_to(@featured_feed, :notice => 'Featured feed was successfully created.') }
        format.xml  { render :xml => @featured_feed, :status => :created, :location => @featured_feed }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @featured_feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /featured_feeds/1
  # PUT /featured_feeds/1.xml
  def update
    @featured_feed = FeaturedFeed.find(params[:id])

    respond_to do |format|
      if @featured_feed.update_attributes(params[:featured_feed])
        format.html { redirect_to(@featured_feed, :notice => 'Featured feed was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @featured_feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /featured_feeds/1
  # DELETE /featured_feeds/1.xml
  def destroy
    @featured_feed = FeaturedFeed.find(params[:id])
    @featured_feed.destroy

    respond_to do |format|
      format.html { redirect_to(featured_feeds_url) }
      format.xml  { head :ok }
    end
  end
  
  def move_up
    @featured_feed = FeaturedFeed.find(params[:id])
    @featured_feed.move_up
    
    redirect_to featured_feeds_url    
  end

  def move_down
    @featured_feed = FeaturedFeed.find(params[:id])
    @featured_feed.move_down
    
    redirect_to featured_feeds_url    
  end
    
end
