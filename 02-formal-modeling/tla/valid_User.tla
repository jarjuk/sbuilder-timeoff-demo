(*
 * Validate data model entry user
 *)
valid_User( user ) ==
                  user # Nil
             /\   user.user_name # Nil
             /\   user.user_lastname # Nil
             /\   user.user_email # Nil
