FactoryGirl.define do
  factory :permission do
    role
    action { Permission.actions.map(&:second).sample }

    factory :permission_with_subject do
      subject { create(:category) }
      subject_type 'Category'
    end
  end
end
