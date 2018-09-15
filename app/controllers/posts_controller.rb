class PostsController < ApplicationController
  before_action :set_post, only: [:confirm, :edit, :update]
  before_action :new_post, only: [:show, :new]

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    if Post.last.present?
      next_id = Post.last.id + 1
    else
      next_id = 1
    end
    make_picture(next_id)
    if @post.save
      redirect_to confirm_path(@post)
    else
      render :new
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    if @post.update(post_params)
      make_picture(@post.id)
      redirect_to confirm_path(@post)
      else
        render :edit
      end
  end

  def confirm
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    def new_post
      @post = Post.new
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:content, :picture, :kind)
    end
    #画像を作成するためのメソット
    def make_picture(id)
      sentense = ""
      content = @post.content.gsub(/\r\n|\r|\n/,"")
      #文字数によって文字を設定
      if content.length < 28 then
        n = (content.length / 7).floor + 1
        n.times do |i|
          s_num = i*7
          f_num = s_num + 6
          range = Range.new(s_num, f_num)
          sentense += content.slice(range)
          sentense + = "\n" if n != i+ 1
        end
      pointsize = 90

      elsif content.length <= 50 then
        n = (content.length / 10).floor + 1
        n.times do |i|
          s_num = i * 10
          f_num = s_num + 9
          range =  Range.new(s_num,f_num)
          sentense += content.slice(range)
          sentense += "\n" if n != i+1
        end
      pointsize = 60

      else
        n = (content.length / 15).floor + 1
        n.times do |i|
          s_num = i * 15
          f_num = s_num + 14
          range =  Range.new(s_num,f_num)
          sentense += content.slice(range)
          sentense += "\n" if n != i+1
        end
      pointsize = 45
      end
      color = "black"
      draw = "text 0,0 '#{sentense}'"
      font = ".fonts/GenEiGothicN-U-KL.otf"

      case @post.kind
      when "black" then
        base = base = "app/assets/images/black.jpg"
      else
        base = "app/assets/images/red.jp"
      end
      image = MiniMagik::Image.open(base)
      image.combine_options do |i|
        i.font font
        i.fill color
        i.gravity 'center'
        i.pointsize pointsize
        i.draw draw
      end

      storage = Fog::Storage.new(
        provider: 'AWS',
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        region: 'ap-northeast-1'
      )
      case Rails.env
      when 'production'
        # ⑨-14 バケットの指定・URLの設定
        bucket = storage.directories.get('[アプリ名]-production')
        # ⑨-15 保存するディレクトリ、ファイル名の指定（ファイル名は投稿id.pngとしています）
        png_path = 'images/' + id.to_s + '.png'
        image_uri = image.path
        file = bucket.files.create(key: png_path, public: true, body: open(image_uri))
        @post.picture = 'https://s3-ap-northeast-1.amazonaws.com/[アプリ名]-production' + "/" + png_path
      when 'development'
        bucket = storage.directories.get('[アプリ名]-development')
        png_path = 'images/' + id.to_s + '.png'
        image_uri = image.path
        file = bucket.files.create(key: png_path, public: true, body: open(image_uri))
        @post.picture = 'https://s3-ap-northeast-1.amazonaws.com/[アプリ名]-development' + "/" + png_path
      end
    end

end
