(*
 * Add new companry entry to model state - if it does not exist
*)
macro TimeoffAddCompany( company ) {
    
    if ( ~ company \in Timeoff_Companies ) {
          Timeoff_Companies := Timeoff_Companies \union { company };
    };
}
