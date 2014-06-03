class ProductsController < ApplicationController

  before_action :set_product, only: [:show, :edit, :update, :destroy]
  # GET /products
  # GET /products.json
  def index
    @search = Product.search(params[:q])
   
    if params[:q].present?
      cookies.permanent.signed[:search_keyword] = {
        value: params[:q]
      }
    else
      cookies.permanent.signed[:search_keyword] = {
        value: ""
      }
    end
    @products = @search.result
    @search.build_condition
  end

  # GET /products/1
  # GET /products/1.json
  def show
    if request.remote_ip == "0.0.0.0" or request.remote_ip == "127.0.0.1" or request.env['HTTP_X_FORWARDED_FOR'] == "127.0.0.1"
      location = GeoIP.new("#{Rails.root}/public/GeoIP.dat").country("122.176.115.234").country_code2
    else
      location = GeoIP.new("#{Rails.root}/public/GeoIP.dat").country("#{request.remote_ip}").country_code2
    end
    user_agent = request.user_agent.downcase
    ip_address = request.remote_ip
    search_keyword = cookies.permanent.signed[:search_keyword]
    user_tracking_code = cookies.permanent.signed[:tracking_code]
    
    @product.create_activity key: 'product.view_detail', parameters: {:ip_address=>ip_address, :search_keyword=>search_keyword,
    :user_agent=>user_agent, :geo_location=>location, :user_tracking_code=>user_tracking_code}
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
    @product_tags = @product.tags.map(&:attributes)
  end

  # POST /products
  # POST /products.json
  def create
    params[:product][:tag_ids] = Array.new
    params[:tags].split(",").each do |tag|
      tag_detail = Tag.where("title = ?",tag).first
      if tag_detail.present?
        params[:product][:tag_ids] << tag_detail.id
      else
        new_tag = Tag.new(:title=>tag)
        new_tag.save
        params[:product][:tag_ids] << new_tag.id
      end
    end
    
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    
    params[:product][:tag_ids] = Array.new
    params[:tags].split(",").each do |tag|
      tag_detail = Tag.where("title = ?",tag).first
      if tag_detail.present?
        params[:product][:tag_ids] << tag_detail.id
      else
        new_tag = Tag.new(:title=>tag)
        new_tag.save
        params[:product][:tag_ids] << new_tag.id
      end
    end
    
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def get_tags
		@tags = Tag.where("title like ?", "%#{params[:q]}%")
     respond_to do |format|
       format.html
       format.json { render :json => @tags.map(&:attributes)}
     end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :price, :description, :tag_ids => [])
    end
end
