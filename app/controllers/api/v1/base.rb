require "grape-swagger"

module API  
  module V1
    class Base < Grape::API
      mount API::V1::ClinicalTrials
      mount API::V1::MessageTemplates
      # mount API::V1::Messages
      
      add_swagger_documentation(
        api_version: "v1",
        add_version: true,
        mount_path: "/api/v1/swagger_doc",
        hide_documentation_path: true,
        hide_format: true
      )
    end
  end
end  