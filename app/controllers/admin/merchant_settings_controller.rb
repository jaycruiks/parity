module Admin
  class MerchantSettingsController < Admin::ApplicationController
    def find_resource(param)
      MerchantSetting.current
    end

    def resource_params
      params.require(:merchant_setting).permit(*dashboard.permitted_attributes)
    end
  end
end
