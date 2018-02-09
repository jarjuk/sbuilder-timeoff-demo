(*
 * Evaluate TRUE whe service /registerCompany(post)
 * succeeds i.e. return status 200.
*)
isCompanyRegistered == InfrastructureServiceGetStatus("/registerCompany(post)") = "status_200"
