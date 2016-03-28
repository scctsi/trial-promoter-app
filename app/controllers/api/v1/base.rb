module API  
  module V1
    class Base < Grape::API
      mount API::V1::ClinicalTrials
      mount API::V1::Messages
      mount API::V1::MessageTemplates
    end
  end
end  