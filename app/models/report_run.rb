class ReportRun < ActiveRecord::Base
  belongs_to :user
  belongs_to :report
  belongs_to :property
end
