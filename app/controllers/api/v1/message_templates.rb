module API  
  module V1
    class MessageTemplates < Grape::API
      include API::V1::Defaults

      resource :message_templates do
        desc "Return all message templates."
        get "", root: :message_templates do
          MessageTemplate.all
        end
        
        # desc 'Create a clinical trial.'
        # params do
        #   requires :title, type: String, desc: "The official title of the clinical trial"
        #   requires :pi_first_name, type: String, desc: "The Primary Investigator's first name"
        #   requires :pi_last_name, type: String, desc: "The Primary Investigator's last name"
        #   requires :url, type: String, desc: "The URL of the landing page for the clinical trial"
        #   requires :disease, type: String, desc: "The lay friendly disease term for the clinical trial"
        #   optional :nct_id, type: String, desc: "The NCT number assigned by clinicaltrials.gov for the clinical trial"
        # end
        # post do
        #   clinical_trial = ClinicalTrial.create!(
        #     title: params[:title],
        #     pi_first_name: params[:pi_first_name],
        #     pi_last_name: params[:pi_last_name],
        #     url: params[:url],
        #     disease: params[:disease],
        #     nct_id: params[:nct_id]
        #   )
        #   {:id => clinical_trial.id}
        # end
      end
    end
  end
end  