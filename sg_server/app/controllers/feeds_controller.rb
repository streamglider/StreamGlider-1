class FeedsController < ApplicationController
  
  before_filter :authenticate_admin!, :except => :index
  
  # GET /feeds
  # GET /feeds.xml
  def index
    #display only top level feeds (without parent)
    @feeds = Feed.where(:parent_id => nil).order('position ASC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @feeds }
    end
  end

  # GET /feeds/1
  # GET /feeds/1.xml
  def show
    @feed = Feed.find(params[:id])  
    
    if @feed.leaf
      render_error
      return
    end
    
    @contains_leaf_nodes = @feed.parent != nil && @feed.parent.parent != nil        
    
    @children = @feed.children.order('position ASC')  
      
  end

  # GET /feeds/new
  # GET /feeds/new.xml
  def new
    @feed = Feed.new
    @feed.leaf = params[:leaf]
    
    if (params[:parent_id])
      @feed.parent = Feed.find params[:parent_id]
    end
    
    if @feed.leaf && !@feed.parent
      render_error
      return
    end
      
  rescue
    render_error  
  end

  # GET /feeds/1/edit
  def edit
    @feed = Feed.find(params[:id])
  end

  # POST /feeds
  # POST /feeds.xml
  def create
    @feed = Feed.new(params[:feed])

    if @feed.leaf && !@feed.url
      render_error
      return
    end
    
    if !@feed.leaf && @feed.url
      render_error
      return
    end

    @feed.position = @feed.parent ? (@feed.parent.children.count + 1) : (Feed.where(:parent_id => nil).count + 1)

    if @feed.save
      if @feed.parent
        n = @feed.leaf ? 'Feed was successfully created.' : 'Sub-Category was successfully created'
        redirect_to(@feed.parent, :notice => n)
      else
        redirect_to(feeds_url, :notice => 'Category was successfully created.')
      end  
    else
      render :action => "new"
    end
  end

  # PUT /feeds/1
  # PUT /feeds/1.xml
  def update
    @feed = Feed.find(params[:id])

    if @feed.update_attributes(params[:feed])
      if @feed.parent
        n = @feed.leaf ? 'Feed was successfully updated.' : 'Sub-Category was successfully updated'
        redirect_to(@feed.parent, :notice => n)
      else
        redirect_to(feeds_url, :notice => 'Category was successfully updated.')
      end  
    else
      render :action => "edit"
    end
  end

  # DELETE /feeds/1
  # DELETE /feeds/1.xml
  def destroy
    @feed = Feed.find(params[:id])
    parent  = @feed.parent
    @feed.destroy
    
    if parent
      redirect_to(parent)    
    else
      redirect_to(feeds_url)    
    end  
    
  rescue
    render_error  
  end
  
  def move_up
    @feed = Feed.find(params[:id])
    @feed.move_up
    
    if @feed.parent
      redirect_to @feed.parent
    else  
      redirect_to feeds_url    
    end
  end

  def move_down
    @feed = Feed.find(params[:id])
    @feed.move_down
    
    if @feed.parent
      redirect_to @feed.parent
    else  
      redirect_to feeds_url    
    end
    
  end  
  
  def clear_image
    feed = Feed.find(params[:id])
    feed.image = nil
    feed.save!
    
    redirect_to edit_feed_url(feed)
    
  rescue
    render_error  
  end
  
  def sort
    fid = params[:id]
    feed = nil
    if fid
      feed = Feed.find(params[:id])    
      children = feed.children.map { |f| f }
    else
      children = Feed.where(:parent_id => nil).map { |f| f }
    end
    
    children.sort! { |x, y| x.title <=> y.title }
    
    index = 1
    children.each do |f|
      f.position = index
      f.save!
    end

    if feed
      redirect_to feed
    else
      redirect_to feeds_path
    end  
    
  rescue
    render_error      
  end
  
end
