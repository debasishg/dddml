open Base 
open Id
open CalendarLib
open Calendar

(* account number and validation *)
module Account_No = struct
  include String_id

  let validate = 
    let open Validator in
    (string_has_max_length 12 "Too long")
    |> compose
      (string_has_min_length 3 "Too short")

end

(* account name and validation *)
module Account_Name = struct
  include String_id

  let validate = 
    let open Validator in
    string_is_not_empty "Empty"

end

type currency = USD | JPY | INR | GBP

type account_type = 
  | Trading of currency           (* with trading currency *)
  | Settlement of currency        (* with settlement currency *)
  | Both of currency * currency   (* with trading and settlement currency *)

type account_base = {
  no: Account_No.t;
  name: Account_Name.t;
  date_of_open: CalendarLib.Calendar.t;
  date_of_close: CalendarLib.Calendar.t option;
}

module type Account_sig = sig
  type t

  (* create a trading account *)
  val create_trading_account: 
    no: Account_No.t -> name: Account_Name.t -> trading_currency: currency -> account_open_date: CalendarLib.Calendar.t -> t

  (* create a settlement account *)
  val create_settlement_account: 
    no: Account_No.t -> name: Account_Name.t -> settlement_currency: currency -> account_open_date: CalendarLib.Calendar.t -> t

  (* create a trading and settlement account *)
  val create_both_account: 
    no: Account_No.t -> name: Account_Name.t -> trading_currency: currency -> settlement_currency: currency -> account_open_date: CalendarLib.Calendar.t -> t

  (* close an account *)
  val close: account: t -> date_of_close: CalendarLib.Calendar.t -> (t, string) Result.t

  (* get the account type *)
  val account_type: t -> account_type
end

module Account : Account_sig = struct
  type t = {
    base: account_base;
    account_type: account_type;
  }

  let create_trading_account ~no ~name ~trading_currency ~account_open_date = 
    let base = {
      no;
      name;
      date_of_open = account_open_date;
      date_of_close = None;
    } in
    { 
      base = base; 
      account_type = Trading trading_currency 
    }

  let create_settlement_account ~no ~name ~settlement_currency ~account_open_date = 
    let base = {
      no;
      name;
      date_of_open = account_open_date;
      date_of_close = None;
    } in
    { 
      base = base; 
      account_type = Settlement settlement_currency 
    }

  let create_both_account ~no ~name ~trading_currency ~settlement_currency ~account_open_date = 
    let base = {
      no;
      name;
      date_of_open = account_open_date;
      date_of_close = None;
    } in
    { 
      base = base; 
      account_type = Both (trading_currency, settlement_currency)
    }

  (* private *)
  let validate_close ~account: t ~date_of_close = match t.base.date_of_close with 
    | Some _ -> Error "Account is already closed"
    | None ->  match compare t.base.date_of_open date_of_close with
      | 0 -> Error "Account open and close date cannot be the same"
      | 1 -> Error "Account open date cannot be after close date"
      | _ -> Ok t

  let close ~account: t ~date_of_close =
    let open Result in
    validate_close ~account: t ~date_of_close >>= fun _ ->
    Ok { 
      t with base = { 
        t.base with date_of_close = Some date_of_close 
      } 
    }

  let account_type t = t.account_type

end


(* 
  #require "Calendar";; 
  open CalendarLib;;
  open Date;;
  open Printer;;

  make 2018 10 29;;
*)