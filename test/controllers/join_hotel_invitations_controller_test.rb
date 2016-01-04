require 'test_helper'

describe JoinHotelInvitationsController do
  include Devise::TestHelpers

  describe "GET#accept" do
    let(:current_property) { Property.current  }
    let(:sender) { create(:user) }

    it 'should connect the user to the new hotel' do
      create(:property).run_block do
        @invitee = create(:user)
      end

      @test_dep1 = create(:department, name: 'test_dep')
      @test_dep2 = create(:department, name: 'test_dep2')

      params = {
        "remove_avatar"=>"0", "name"=>"GD", 
        "current_property_user_role_attributes"=> {"title"=>"test", "order_approval_limit"=>"10", "role_id"=> Role.gm.id}, 
        "email"=>"gd@test.com", "department_ids"=>["", @test_dep1.id.to_s, @test_dep2.id.to_s]
      }

      invitation = JoinHotelInvitation.create(sender: sender, invitee: @invitee, property: current_property, params: params)

      sign_in @invitee

      @invitee.all_properties.include?(current_property).must_equal false

      get :accept, id: invitation.id

      @invitee.all_properties.include?(current_property).must_equal true
    end

    it 'must give them the correct role, department, approval limit etc when joining' do
      create(:property).run_block do
        @invitee = create(:user, current_property_role: Role.manager, title: "Test Manager", order_approval_limit: 100)
      end

      @test_dep1 = create(:department, name: 'test_dep')
      @test_dep2 = create(:department, name: 'test_dep2')

      params = {
        "remove_avatar"=>"0", "name"=>"GD", 
        "current_property_user_role_attributes"=> {"title"=>"test", "order_approval_limit"=>"10", "role_id"=> Role.gm.id}, 
        "email"=>"gd@test.com", "department_ids"=>["", @test_dep1.id.to_s, @test_dep2.id.to_s]
      }

      invitation = JoinHotelInvitation.create(sender: sender, invitee: @invitee, property: current_property, params: params)


      sign_in @invitee

      get :accept, id: invitation.id

      @invitee.current_property_role.must_equal Role.manager
      @invitee.departments.include?(@test_dep1).must_equal false
      @invitee.departments.include?(@test_dep2).must_equal false
      @invitee.order_approval_limit.must_equal 100
      @invitee.title.must_equal "Test Manager"

      current_property.switch!
      @invitee.reload
      @invitee.current_property_role.must_equal Role.gm
      @invitee.departments.include?(@test_dep1).must_equal true
      @invitee.departments.include?(@test_dep2).must_equal true
      @invitee.order_approval_limit.must_equal 10
      @invitee.title.must_equal "test"
    end
  end
end
