(*
 * All user and company entries in formal model state are valid
*)
correct_Database == \A user \in Timeoff_Users: valid_User(user)
                 /\ \A co \in Timeoff_Companies: valid_Company(co)
