(* some sample currencies for the time being *)
type currency = USD | JPY | INR | GBP

(* account_type will be trading, settlement or both *)
type account_type = 
  | Trading of currency           (* with trading currency *)
  | Settlement of currency        (* with settlement currency *)
  | Both of currency * currency   (* with trading and settlement currency *)

module type Account_sig = sig
  type t
  type account_no
  type account_name

  (* create a trading account *)
  val create_trading_account: 
    no: account_no -> name: account_name -> trading_currency: currency -> account_open_date: CalendarLib.Calendar.t -> t

  (* create a settlement account *)
  val create_settlement_account: 
    no: account_no -> name: account_name -> settlement_currency: currency -> account_open_date: CalendarLib.Calendar.t -> t

  (* create a trading and settlement account *)
  val create_both_account: 
    no: account_no -> name: account_name -> trading_currency: currency -> settlement_currency: currency -> account_open_date: CalendarLib.Calendar.t -> t

  (* close an account *)
  val close: account: t -> date_of_close: CalendarLib.Calendar.t -> (t, string) Result.t

  (* get the account type *)
  val account_type: t -> account_type
end