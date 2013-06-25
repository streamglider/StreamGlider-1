class ShareTosController < ApplicationController
  
  before_filter :authenticate_user!
  
  # GET /share_tos.json
  def index
    @share_tos = current_user.incoming_streams    
    render :json => @share_tos    
  end

  # DELETE /share_tos/1
  # DELETE /share_tos/1.xml
  def destroy
    @share_to = ShareTo.find(params[:id])
    
    unless @share_to.user == current_user
      render_json_error
      return
    end
    
    # destroy shared stream as well
    @share_to.stream.destroy
    
    @share_to.destroy
    
    render :json => { :status => 'OK' }
    
  rescue
    render_json_error  
  end
  
end
