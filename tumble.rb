require 'lib'

dir = Dir['*']
folders = []
selected_files = []

dir.each do |file|
	if File.stat(file).directory?
	folders.push(file)
	end
end

# I bet there are cleaner way to do this but this basically goes down into every folder, 
#upload and deletes anything and goes back to the initial folder. 

folders.each do |folder|
  Dir.chdir( folder ) do
  puts 'deleting older files from ' + folder.to_s 
  # Checks if there are file to delete. Right now deletes older, already uploaded files. 
  # files are renamed when uploaded to filename-tumbled.jpg so they don't get pushed trough again.
  delete_already_uploaded 
  puts 'uploading files from ' + folder.to_s 
  upload_files_to(folder)
  end
end
