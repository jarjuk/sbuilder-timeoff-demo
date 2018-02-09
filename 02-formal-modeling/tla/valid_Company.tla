(*
 * Validate data model entry companry
 *)
valid_Company( co ) ==
                  co # Nil
             /\   co.company_name # Nil
