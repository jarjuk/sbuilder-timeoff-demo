  
# Fill in form register 'John' with password 123
def ui_register_form_fill( registerEntry )
  # COrrect page where
  support_ui_debug "ui_register_form_fill: registerEntry=#{registerEntry}"
  expect( find("#company_name_inp"))

  fill_in 'company_name_inp', :with => registerEntry['name']
  fill_in 'First Name', :with => registerEntry["name"] 
  fill_in 'Last Name', :with => registerEntry["lastname"]
  fill_in 'email_inp', :with => registerEntry["email"] 
  fill_in 'pass_inp', :with => registerEntry["password"] ||  '123'
  fill_in 'confirm_pass_inp', :with => registerEntry["password"] ||  '123'
end

def ui_register_form_submig
  click_button "submit_registration"
end
