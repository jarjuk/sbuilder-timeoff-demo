(*
 * Add new user entry to model state - if it does not exist
*)
macro TimeoffAddUser( user ) {
    
    if ( ~ user \in Timeoff_Users ) {
          Timeoff_Users := Timeoff_Users \union { user };
    };
}
