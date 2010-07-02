require 'rubygems'
require 'ruby-multipart-post'
require 'active_support'

	def rename_jpegs_to_jpgs
	files = Dir['*.jpeg']
		files.each do |filename|
		filerenamed = filename.gsub('.jpeg', '') + '.jpg'	
		File.rename(filename, filerenamed)
		end
	end

	def select_files_to_upload
	rename_jpegs_to_jpgs
	files = Dir['*.jpg']
	files.delete_if {|file| file.include? '-tumbled' }
	@selected_files = []
		files.each do |file|
		@selected_files.push(file)
		end
	end

	def select_older_than(older_than)
	files = Dir['*-tumbled*']
	@selected_files = []
		files.each do |file|
			if File.stat(file).mtime < older_than
			@selected_files.push(file)	
			end
		end
	end

	def delete_already_uploaded
	select_older_than(7.days.ago)
		if @selected_files.empty?
		puts 'No new files to delete'
		else	
			@selected_files.each do |file|
			File.delete(file)
			print '.'
			end
		puts ''
		puts 'Older Files successfuly deleted.'
		end
	end

	def upload_files_to(tumblr)
	select_files_to_upload
		if @selected_files.empty?
		puts 'no new files to upload'
		else
			@selected_files.each do |file|
			@post = Photo.new(file, tumblr)
			@post.build_request
			@post.upload
			end
		end
	end

class Photo 

attr_accessor :file, :email, :password, :group

	def initialize(filename, folder)
	@file = filename
	@email = ''
	@password = ''
	  if folder == 'default'
	  @group = nil
	  else
	  @group = folder + '.tumblr.com'
	  end
	end

	def build_request
	@request = MultiPart::Post.new(	'data' 	=> FileUploadIO.new(@file, 'image/jpg'),
	'email'		=> @email,
	'password'	=> @password,
	'type'		=> 'photo',
	'state'		=> 'queue',
	'group'     => @group )
	
	end
	
	def upload
	@result = @request.submit('http://www.tumblr.com/api/write')
		if @result.code == '201'
		print '.'
		rename(@file)
		else
		puts "#{@file} upload failed"
		puts "Status: #{@result.code} #{@result.message}"
		end
	end
	
	def rename(filename)
	filerenamed = filename.gsub('.jpg', '') + '-tumbled' + '.jpg'	
	File.rename(filename, filerenamed)
	end

end
