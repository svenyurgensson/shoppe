module Shoppe
  class BlogPostsController < Shoppe::ApplicationController
    before_filter { @active_nav = :posts }
    before_filter { params[:id] && @post = Shoppe::Blog::Post.find(params[:id]) }

    def index
      @posts = Shoppe::Blog::Post.page(params[:page])
    end

    def new
      @post = Shoppe::Blog::Post.new
    end

    def edit
    end

    def create
      @post = Shoppe::Blog::Post.new(safe_params)
      if @post.save
        @post.set_tags!(params[:blog_post][:tags_string])
        @post.save
        redirect_to :blog_posts, notice: t('shoppe.post.create_notice')
      else
        render action: 'new'
      end
    end

    def update
      if @post.update(safe_params)
        @post.clear_tags!
        @post.set_tags!(params[:blog_post][:tags_string])
        @post.save
        redirect_to [:edit, @post], notice: t('shoppe.post.update_notice')
      else
        render action: 'edit'
      end
    end

    def destroy
      @post.clear_tags!
      @post.destroy
      redirect_to :blog_posts, notice: t('shoppe.post.destroy_notice')
    end

    private

    def safe_params
      params[:blog_post].permit(
        :title,
        :permalink,
        :permalink,
        :published,
        :raw_content,
        :tags_string,
      )
    end
  end
end
