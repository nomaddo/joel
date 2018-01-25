open Syntax
open Common
open List

exception Type_not_applicable of string * string
exception Typecheck_failed of string
exception Undefined_variable of string

(* tsubs e a t ~> e{t/a} *)
(* let rec tsubs tr a ty = *)
(* match tr with *)
(* | Add(e1, e2) -> Add(tsubs e1 a ty, tsubs e2 a ty) *)
(* | Sub(e1, e2) -> Sub(tsubs e1 a ty, tsubs e2 a ty) *)
(* | Mul(e1, e2) -> Mul(tsubs e1 a ty, tsubs e2 a ty) *)
(* | Div(e1, e2) -> Div(tsubs e1 a ty, tsubs e2 a ty) *)
(* | App(fn, args) -> App(tsubs fn a ty, tsubs args a ty) *)
(* | Lamb(x, b, body) -> Lamb(x, ttsubs b a ty, tsubs body a ty) *)
(* | Data(k, tys, es) -> *)
(* Data(k, *)
(* tys |> map (fun ty' -> ttsubs ty' a ty), *)
(* es |> map (fun tr' -> tsubs tr' a ty)) *)
(* | Match(c, alt) -> *)
(* Match(tsubs c a ty, alt |> map @@ fun (k, es, u) -> *)
(* (k, es |> map (fun (x, ty') -> (x, ttsubs ty' a ty)), tsubs u a ty)) *)
(* | MatchVal(c, valt) -> *)
(* MatchVal(tsubs c a ty, valt |> map @@ fun (va, u) -> (va, tsubs u a ty)) *)
(* | Let(x, ty', bde, body) -> *)
(* Let(x, ttsubs ty' a ty, tsubs bde a ty, tsubs body a ty) *)
(* | Letrec(vbs, body) -> *)
(* Letrec(vbs |> map (fun (x, ty', bde) -> (x, ttsubs ty' a ty, tsubs bde a ty)), tsubs body a ty) *)
(* | Join(j, tvars, vars, bde, body) -> *)
(* Join(j, tvars, vars |> map (fun (x, ty') -> (x, ttsubs ty' a ty)), tsubs bde a ty, tsubs body a ty) *)
(* | Joinrec(jbs, body) -> *)
(* Joinrec(jbs |> map (fun (j, tvars, vars, bde) -> *)
(* (j, tvars, vars |> map (fun (x, ty') -> (x, ttsubs ty' a ty)), tsubs bde a ty) *)
(* ), tsubs body a ty) *)
(* | Jump(j, tys, trs, ty') -> *)
(* Jump(j, tys |> map (fun ty' -> ttsubs ty' a ty), trs |> map (fun tr -> tsubs tr a ty), ttsubs ty a ty') *)
(* | Try(e, exc) -> Try(tsubs e a ty, exc |> map (fun (k, args, u) -> (k, args, tsubs u a ty))) *)
(* | Exn(ex, trs) -> Exn(ex, trs |> map @@ fun t -> tsubs t a ty) *)
(* | True | False | Unit | Int _ | Var _ | Tlamb(_, _) -> tr *)
(* | _ -> tr *)
(* ttsubs ty a ty' ~> ty{ty'/a} *)
let rec ttsubs ty a ty' =
  match ty with
  | TVar b when a = b -> ty'
  | TData(k, params, data) ->
    let params' = params |> map @@ fun b ->
      if a = b then ty' else TVar b in
    TDataRef(k, params')
  | TDataRef(tyname, tvars) -> TDataRef(tyname, tvars |> map @@ fun t -> ttsubs t a ty')
  | Arrow(ta, te) ->  Arrow(ttsubs ta a ty', ttsubs te a ty')
  | Ttapp(ta, te) ->
    Ttapp(ttsubs ta a ty', ttsubs te a ty')
  | Univ(b, t) when b <> a -> Univ(b, ttsubs t a ty')
  | Hole | Bool | Base | TUnit | TVar _ | Univ(_, _) | TInt | TExn -> ty

(* let tapp ut ty' = *)
(* match ut with *)
(* | Univ(a, ty) -> ttsubs ty a ty' *)
(* | TData(k, params, _) -> *)
(* let params' = params |> map @@ fun a -> TVar a in *)
(* if List.length params' > 1 then *)
(* TDataRef(k, ty' :: (List.tl params')) *)
(* else if List.length params' = 0 then *)
(* TDataRef(k, [ty']) *)
(* else *)
(* raise @@ Type_not_applicable((rawstring_of_type ut), (rawstring_of_type ty')) *)
(* | TDataRef(k, tys) -> TDataRef(k, ty' :: tys) *)
(* | _ -> raise @@ Type_not_applicable((rawstring_of_type ut), (rawstring_of_type ty')) *)

(* let rec fullapp ut tys = *)
(* match ut with *)
(* | Univ(a, ty) -> *)
(* begin match tys with *)
(* | ty' :: tys' -> fullapp (ttsubs ty a ty') tys' *)
(* | _ -> raise @@ Type_not_applicable((rawstring_of_type ut), "") *)
(* end *)
(* | _ -> ut *)

(* let rec typeof tdefs tenv delta u = *)
(* match u with *)
(* | True | False -> Bool *)
(* | Int _ -> TInt *)
(* | Add(e1, e2) | Sub(e1, e2) | Div(e1, e2) | Mul(e1, e2) -> *)
(* if (compare_type TInt @@ typeof tdefs tenv delta e1) && *)
(* (compare_type TInt @@ typeof tdefs tenv delta e2) then *)
(* TInt *)
(* else *)
(* raise @@ Typecheck_failed (rawstring_of_term u) *)
(* | Unit -> TUnit *)
(* | Var v -> *)
(* begin match lookup tenv v with *)
(* | Some ty -> ty *)
(* | None -> raise @@ Undefined_variable v *)
(* end *)
(* | Lamb(x, ty, tr) -> Arrow(ty, typeof tdefs ((x, ty) :: tenv) [] tr) *)
(* | App(fn, arg) -> *)
(* begin match typeof tdefs tenv delta fn with *)
(* | Arrow(a, b) when a = (typeof tdefs tenv [] arg) -> b *)
(* | _ -> raise @@ Typecheck_failed (rawstring_of_term u) *)
(* end *)
(* | Let(x, ty, bde, body) -> *)
(* let tybde = typeof tdefs tenv [] bde in *)
(* if compare_type ty tybde then *)
(* let tenv' = (x, ty) :: tenv in *)
(* typeof tdefs tenv' delta body *)
(* else raise @@ Typecheck_failed (rawstring_of_term u) *)
(* | Letrec(vbs, body) -> *)
(* let tenv' = fold_left (fun tenv (x, ty, bde) -> ((x, ty) :: tenv)) tenv vbs in *)
(* let () = ignore begin vbs |> map @@ fun (x, ty, bde) -> *)
(* if not @@ compare_type ty @@ typeof tdefs tenv' delta bde then *)
(* raise @@ Typecheck_failed (rawstring_of_term bde) *)
(* end *)
(* in *)
(* typeof tdefs tenv' delta body *)
(* | Data(k, tys, es) -> *)
(* let tyk (* T a *) = ktypeof tdefs k in *)
(* let tvars (* a *), targs (* σ *) = vars_of_type tyk in *)
(* let targs' (* u{φ/a} *) = *)
(* let m0 = map2 (fun phi sigma -> (phi, sigma)) tys tvars in *)
(* map2 (fun sigma (phi, a) -> ttsubs sigma a phi) targs m0 in *)
(* let () = ignore @@ map2 begin fun u ty -> *)
(* if not @@ compare_type (typeof tdefs tenv [] u) ty then *)
(* raise @@ Typecheck_failed (rawstring_of_term u) *)
(* end es targs' *)
(* in *)
(* let tt = (fold_left (fun ty t -> tapp ty t) tyk targs') in *)
(* let (arrargs, t) = *)
(* let rec digarrow = function *)
(* | Arrow(a, t) -> *)
(* let (arr, t') = digarrow t in *)
(* (a::arr, t') *)
(* | t -> ([], t) *)
(* in *)
(* digarrow tt in *)
(* let () = (* TODO: compare digarrow[i] to es[i] *) () in *)
(* t *)
(* | Match(c, alt) as u -> *)
(* begin match typeof tdefs tenv delta c with *)
(* | TDataRef(k, phis) -> *)
(* let altconts = alt |> map @@ fun (k, args, u) -> (ktypeof tdefs k, args, u) in *)
(* let ts = altconts |> map @@ fun (tyk, args, u') -> *)
(* let tvars, targs = vars_of_type tyk in *)
(* let targs' = targs |> map  @@ fun sigma -> *)
(* fold_left2 begin fun ty a phi -> *)
(* ttsubs ty a phi *)
(* end sigma tvars phis in *)
(* let tenv' = fold_left2 begin fun tenv (x, nu) ta -> *)
(* if not @@ compare_type nu ta then *)
(* raise @@ Typecheck_failed (rawstring_of_term u) *)
(* else (x, nu) :: tenv *)
(* end tenv args targs' in *)
(* typeof tdefs tenv' delta u' *)
(* in *)
(* (* ∀ t1, t2 ∈ ts. t1 = t2 ? *) *)
(* begin match ts with *)
(* | t :: ts' ->  *)
(* if not @@ exists (compare_type t) ts' then *)
(* raise @@ Typecheck_failed (rawstring_of_term u) *)
(* else t *)
(* | [] -> *)
(* raise @@ Typecheck_failed (rawstring_of_term u) *)
(* end *)
(* | _ -> raise @@ Typecheck_failed (rawstring_of_term u) *)
(* end *)
(* | MatchVal(c, valt) as u -> *)
(* let tyc = typeof tdefs tenv delta c in *)
(* let valtcons = valt |> map @@ fun (va, u') -> *)
(* match va with *)
(* | AInt _ -> *)
(* if not @@ compare_type TInt tyc then *)
(* raise @@ Typecheck_failed (rawstring_of_term u) *)
(* else typeof tdefs tenv delta u' *)
(* | ATrue | AFalse -> *)
(* if not @@ compare_type Bool tyc then *)
(* raise @@ Typecheck_failed (rawstring_of_term u) *)
(* else typeof tdefs tenv delta u' *)
(* | AVar x -> *)
(* typeof tdefs ((x, tyc) :: tenv) delta u' *)
(* in *)
(* begin match valtcons with *)
(* | t :: ts' -> *)
(* if not @@ exists (compare_type t) ts' then *)
(* raise @@ Typecheck_failed (rawstring_of_term u) *)
(* else t *)
(* | [] -> *)
(* raise @@ Typecheck_failed (rawstring_of_term u) *)
(* end *)
(* | Join(j, tvars, vars, bde, body) -> *)
(* let tenv', tyj = fold_left (fun (tenv, ty) tvar -> (tenv, Univ(tvar, ty))) ( *)
(* fold_left (fun (tenv, ty) (x, t) -> (x, t) :: tenv, Arrow(t, ty)) (tenv, Univ("r", TVar("r"))) vars *)
(* ) tvars in *)
(* let tybody = typeof tdefs tenv' ((j, tyj) :: delta) body in *)
(* tybody *)
(* | Joinrec(jbs, body) -> *)
(* let tenv', delta' = fold_left begin fun (tenv, delta) (j, tvars, vars, bde) -> *)
(* let tenv', tyj = *)
(* fold_left (fun (tenv, ty) (x, t) -> (x, t) :: tenv, Arrow(t, ty)) (tenv, Univ("r", TVar("r"))) vars in *)
(* tenv', (j, tyj) :: delta *)
(* end (tenv, delta) jbs *)
(* in typeof tdefs tenv delta' body *)
(* | Jump(j, typlist, termlist, ty) -> *)
(* begin match lookup delta j with *)
(* | Some(tyj) -> *)
(* let tyj' = fullapp tyj typlist in *)
(* let _, targs = vars_of_type tyj' in *)
(* let () = ignore @@ map2 (fun u' sigma -> *)
(* if not @@ compare_type (typeof tdefs tenv [] u') sigma then *)
(* raise @@ Typecheck_failed (rawstring_of_term u)) termlist targs *)
(* in *)
(* ty *)
(* | None -> raise @@ Typecheck_failed (rawstring_of_term u) *)
(* end *)
(* | Exn(k, args) as u -> *)
(* let _, targs = vars_of_type @@ ktypeof tdefs k in *)
(* let () = ignore @@ map2 (fun ty tr -> *)
(* if not @@ compare_type ty @@ typeof tdefs tenv delta tr then *)
(* raise @@ Typecheck_failed (rawstring_of_term u)) targs args *)
(* in TExn *)
(* | Try(e, exc) as u -> *)
(* let tye = typeof tdefs tenv [] e in *)
(* let () = ignore @@ map (fun (k, args, v) -> *)
(* let _, targs = vars_of_type @@ ktypeof tdefs k in *)
(* let tenv' = fold_left2 (fun tenv x phi -> (x, phi) :: tenv) tenv args targs in *)
(* if not @@ compare_type tye @@ typeof tdefs tenv' delta v then *)
(* raise @@ Typecheck_failed (rawstring_of_term u)) exc *)
(* in tye *)
(* and ktypeof tdefs k = *)
(* let rec search_datatype cstr = function *)
(* | [] -> failwith @@ "datatype search error: " ^ k *)
(* | (_, (TData(_, _, ls) as datatype)) :: ts -> *)
(* if List.filter (fun (c, _) -> c = cstr) ls |> List.length = 1 then datatype *)
(* else search_datatype cstr ts *)
(* | _ :: ts -> search_datatype cstr ts *)
(* in *)
(* match search_datatype k tdefs with *)
(* | TData(tname, atys, ks) as tt -> *)
(* let kk, args = find (fun (k', _) -> k' = k) ks in *)
(* let univs = fun ty -> fold_left (fun ty' a -> Univ(a, ty')) ty atys in *)
(* let arrows = fun ty -> fold_left (fun ty' sigma -> Arrow(sigma, ty')) ty args in *)
(* let tyapp = fold_left (fun ty a -> Ttapp(ty, TVar a)) tt atys in *)
(* univs @@ arrows tyapp *)
(* | e -> e *)

