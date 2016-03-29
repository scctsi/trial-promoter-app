module API  
  module V1
    class MessageTemplates < Grape::API
      include API::V1::Defaults

      resource :message_templates do
        desc "Return all message templates."
        get "", root: :message_templates do
          MessageTemplate.all
        end
        
        desc 'Create a message template.'
        params do
          requires :content, type: String, desc: "The content of the message template (DOCUMENT SUPPORTED PARAMETERS IN TEMPLATE)"
          requires :platform, type: Symbol, values: [:twitter, :facebook]
        end
        post do
          message_template = MessageTemplate.create!(
            content: params[:content],
            platform: params[:platform]
          )
          {:id => message_template.id}
        end
      end
    end
  end
end  