def ui_choose_register
  support_ui_debug "ui_choose_register"
  register_text = "Register new company"
  expect(page).to have_content(register_text)
  click_link register_text
end
