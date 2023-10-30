open Base
open Id

(* account number and validation *)
module Accountno = struct
  include String_id

  let validate = 
    let open Validator in
    (string_has_max_length 12 "Too long")
    |> compose
      (string_has_min_length 3 "Too short")

end

(* account name and validation *)
module Accountname = struct
  include String_id

  let validate = 
    let open Validator in
    string_is_not_empty "Empty"

end