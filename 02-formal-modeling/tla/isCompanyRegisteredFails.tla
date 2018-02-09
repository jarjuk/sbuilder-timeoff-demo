 (*
 * Evaluate TRUE whe service /registerCompany(post)
 * fails  i.e. returns status 400.
 *)
  isCompanyRegisteredFails == InfrastructureServiceGetStatus("/registerCompany(post)") = "status_400"
