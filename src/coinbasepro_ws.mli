open Coinbasepro

type auth = {
  key : string ;
  passphrase : string ;
  timestamp : string ;
  signature : string ;
} [@@deriving sexp]

val auth :
  timestamp:string -> key:string ->
  secret:string -> passphrase:string -> auth

type channel =
  | Heartbeat
  | Ticker
  | Level2
  | User
  | Matches
  | Full
[@@deriving sexp]

type channel_full = {
  chan: channel ;
  product_ids : Pair.t list ;
} [@@deriving sexp]

val heartbeat : Pair.t list -> channel_full
val full : Pair.t list -> channel_full
val matches : Pair.t list -> channel_full
val level2 : Pair.t list -> channel_full

type heartbeat = {
  sequence: int64 ;
  last_trade_id: int64 ;
  product_id: string ;
  time: Ptime.t ;
} [@@deriving sexp]

type order = {
  ts : Ptime.t ;
  product_id : string ;
  sequence : int64 ;
  order_id : Uuidm.t ;
  client_oid : Uuidm.t option ;
  size : float option ;
  remaining_size : float option ;
  price : float option ;
  side : [`Buy | `Sell] ;
  ord_type : [`Limit | `Market] option ;
  ord_status : [`Filled | `Canceled] option ;
  funds : float option ;
} [@@deriving sexp]

val order_encoding : order Json_encoding.encoding

type ord_match = {
  ts : Ptime.t ;
  product_id : string ;
  sequence : int64 ;
  trade_id : int64 ;
  maker_order_id : Uuidm.t ;
  taker_order_id : Uuidm.t ;
  side : [`Buy | `Sell] ;
  size : float ;
  price : float ;
} [@@deriving sexp]

type change = {
  ts : Ptime.t ;
  sequence : int64 ;
  order_id : Uuidm.t ;
  product_id : string ;
  new_size : float option ;
  old_size : float option ;
  new_funds : float option ;
  old_funds : float option ;
  price : float option ;
  side : [`Buy | `Sell] ;
} [@@deriving sexp]

type l2snapshot = {
  product_id : string ;
  bids : (float * float) list ;
  asks : (float * float) list ;
} [@@deriving sexp]

type l2update = {
  ts : Ptime.t ;
  product_id : string ;
  changes : ([`Buy | `Sell] * float * float) list ;
} [@@deriving sexp]

type error = {
  msg : string ;
  reason : string option ;
} [@@deriving sexp]

type t =
  | Heartbeat of heartbeat
  | Subscribe of auth option * channel_full list
  | Unsubscribe of channel_full list
  | Subscriptions of channel_full list
  | Received of order
  | Done of order
  | Open of order
  | LastMatch of ord_match
  | Match of ord_match
  | Change of change
  | L2Snapshot of l2snapshot
  | L2Update of l2update
  | Error of error
[@@deriving sexp]

val subscribe_full : ?auth:auth -> Pair.t list -> t
val subscribe_level2 : ?auth:auth -> Pair.t list -> t

val is_ctrl_msg : t -> bool
val has_seq_gt : int64 -> t -> bool

val pp : Format.formatter -> t -> unit
val encoding : t Json_encoding.encoding
