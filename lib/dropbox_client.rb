require 'dropbox'

class DropboxClient
  def initialize
    @dropbox_client = Dropbox::Client.new(Setting[:dropbox_access_token])
  end
  
  def list_folder(path)
    @dropbox_client.list_folder(path)
  end
  
  def recursively_list_folder(path)
    folders_and_files = {}
    
    folders = list_folder(path)
    
    folders.each do |folder|
      folders_and_files[folder] = list_folder(folder.path_lower)
    end
    
    folders_and_files
  end
  
  def get_file(path)
    @dropbox_client.download(path)
  end
  
  def store_file(dropbox_file_path, body)
    @dropbox_client.upload(dropbox_file_path, body)
  end
end