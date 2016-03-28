module API  
  module V1
    class ClinicalTrials < Grape::API
      include API::V1::Defaults

      resource :clinical_trials do
        desc "Return all clinical trials"
        get "", root: :clinical_trials do
          ClinicalTrial.all
        end
        # desc "Return a graduate"
        # params do
        #   requires :id, type: String, desc: "ID of the 
        #     graduate"
        # end
        # get ":id", root: "graduate" do
        #   Graduate.where(id: permitted_params[:id]).first!
        # end
      end
    end
  end
end  