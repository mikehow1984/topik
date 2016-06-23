class TopicsController < ApplicationController
	helper FormatTimeHelper
	
	def index
		@topics = nil
		unless params[:query].nil? || params[:query].strip.empty?	
			self.geoloc
			@search = Sunspot.search Topic do
				any do
					fulltext(params[:query], :fields => [:title])	
					fulltext(params[:query], :fields => [:content])
					fulltext(params[:query], :fields => [:posts])
				end
			end
			@topics = @search.results
		end
		
		@topics
	end

	def new
		@topic = Topic.new
	end

	def create 
		@topic = Topic.new(topic_params)
		@topic.unix_time = Time.now.to_i
		self.geoloc
		@topic.coord_lat = @lat_lng[0]
		@topic.coord_long = @lat_lng[1]
		
		if @topic.save
			flash[:notice] = "Topic has been created! #{@topic.coord_lat}, #{@topic.coord_long}"
			redirect_to @topic
		else
		end
	end

	def search

	end
	
	def geoloc	
		if defined?(@lat_lng) == nil
			@lat_lng = nil
		end
		unless cookies[:lat_lng].nil?
			@lat_lng = cookies[:lat_lng].split("|")
		end
	end

	def show 
		@topic = Topic.find(params[:id])
		@post = Post.new
	end
	

	private

	def topic_params
		params.require(:topic).permit(:title, :content, :attach, :thumb, :coord_lat, :coord_long, :unix_time, :lat, :long, posts_attributes: [:content])
	end
end
