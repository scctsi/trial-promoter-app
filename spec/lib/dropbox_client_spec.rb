require 'rails_helper'

RSpec.describe DropboxClient do
  before do 
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:dropbox_access_token).and_return(secrets['dropbox_access_token'])
    @dropbox_client = DropboxClient.new
  end
  
  it 'gets a list of the folders in a folder' do
    folders = nil
    
    VCR.use_cassette 'dropbox_client/list_folder_with_folders' do
      folders = @dropbox_client.list_folder('/TCORS/analytics_files/')
    end

    expect(folders.count).to eq(91)
    expect(folders[0].name).to eq('04-19-2017')
    expect(folders[0].path_lower).to eq('/tcors/analytics_files/04-19-2017')
  end
  
  it 'gets a list of the files in a folder' do
    files = nil
    
    VCR.use_cassette 'dropbox_client/list_folder_with_files' do
      files = @dropbox_client.list_folder('/TCORS/analytics_files/04-19-2017')
    end

    expect(files.count).to eq(6)
    expect(files[0].name).to eq('2017-04-19-to-2017-04-19-6hu9ou4xpw5c.xlsx')
    expect(files[0].path_lower).to eq('/tcors/analytics_files/04-19-2017/2017-04-19-to-2017-04-19-6hu9ou4xpw5c.xlsx')
  end
  
  it 'recursively (only 1 level deep) gets a list of all the files in each folder' do
    folders_and_files = nil
    
    VCR.use_cassette 'dropbox_client/recursively_list_folder' do
      folders_and_files = @dropbox_client.recursively_list_folder('/TCORS/analytics_files/')
    end

    expect(folders_and_files.keys.count).to eq(91)
    folders_and_files.each do |folder, files|
      expect(files.count).to eq(6)
    end
  end
  
  it 'gets a file' do
    file = nil
    body= nil
    
    VCR.use_cassette 'dropbox_client/get_file' do
      file, body = @dropbox_client.get_file('/TCORS/analytics_files/04-19-2017/2017-04-19-to-2017-04-19-6hu9ou4xpw5c.xlsx')
    end
    
    expect(file.name).to eq("2017-04-19-to-2017-04-19-6hu9ou4xpw5c.xlsx")
    expect(file.path_lower).to eq('/tcors/analytics_files/04-19-2017/2017-04-19-to-2017-04-19-6hu9ou4xpw5c.xlsx')
  end
end