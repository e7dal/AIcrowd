require 'rails_helper'

RSpec.describe "hosting_institutions/new", type: :view do
  before(:each) do
    assign(:hosting_institution, HostingInstitution.new(
      :institution => "MyString",
      :address => "MyText",
      :description => "MyText",
      :contact_person => "MyString",
      :contact_phone => "MyString",
      :contact_email => "MyString"
    ))
  end

  it "renders new hosting_institution form" do
    render

    assert_select "form[action=?][method=?]", hosting_institutions_path, "post" do

      assert_select "input#hosting_institution_institution[name=?]", "hosting_institution[institution]"

      assert_select "textarea#hosting_institution_address[name=?]", "hosting_institution[address]"

      assert_select "textarea#hosting_institution_description[name=?]", "hosting_institution[description]"

      assert_select "input#hosting_institution_contact_person[name=?]", "hosting_institution[contact_person]"

      assert_select "input#hosting_institution_contact_phone[name=?]", "hosting_institution[contact_phone]"

      assert_select "input#hosting_institution_contact_email[name=?]", "hosting_institution[contact_email]"
    end
  end
end
