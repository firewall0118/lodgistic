class VptController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def create
    @purchase_order = PurchaseOrder.find(params[:id]).decorate
    # check order is able to send through vpt
      # check items unit size ( MUST BE Case & Each )
      # check ...
    unless @purchase_order.vpt_prepare
      redirect_to :back, alert: 'Error on purchase order for VPT' and return
    end
    xml = @purchase_order.vpt_xml

    # this is for test, after confirm all values with USFood, need to convert webservice side to Sidekiq Worker
    send_data xml, filename: 'vtp.xml'
  end

end
