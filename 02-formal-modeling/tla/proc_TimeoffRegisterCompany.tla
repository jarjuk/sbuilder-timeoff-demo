(*
 * Service implementation for interface /registerCompany(post).
 * Adds user and company entities for valid input and returns status 200 for 
 * valid input. For invalid input return status "400".
*)
procedure proc_TimeoffRegisterCompany( input_proc_TimeoffRegisterCompany ) {

proc_TimeoffRegisterCompany_start:

  if (      valid_User( input_proc_TimeoffRegisterCompany )  
       /\   valid_Company( input_proc_TimeoffRegisterCompany )  

     ) {
      TimeoffAddUser( 
	  [ user_name |-> input_proc_TimeoffRegisterCompany.user_name, 
	    user_lastname |-> input_proc_TimeoffRegisterCompany.user_lastname,
	    user_email |-> input_proc_TimeoffRegisterCompany.user_email
	  ] );
      TimeoffAddCompany( 
	  [ 
	    company_name |-> input_proc_TimeoffRegisterCompany.company_name 
	  ] );

      InfrastructureServiceReturn( "/registerCompany(post)", "status_200", Nil );
  }
  else {
      InfrastructureServiceReturn( "/registerCompany(post)", "status_400", Nil );
  };

proc_TimeoffRegisterCompany_exit:
  return;
}
