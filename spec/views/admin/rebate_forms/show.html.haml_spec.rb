# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/rebate_forms/show', type: :view do
  before(:each) do
    @admin_rebate_form = assign(:rebate_form, RebateForm.create!)
  end

  it 'renders attributes in <p>' do
    render
  end
end