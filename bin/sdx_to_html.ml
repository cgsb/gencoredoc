#use "topfind";;
#thread ;;
#require "sequme";;

open Core.Std
open Result 
let template = sprintf "
<!DOCTYPE html>
<html><head>
<link rel=\"stylesheet\" href=\"gdcstyle.css\" type=\"text/css\">
<meta content=\"text/html; charset=utf8\" http-equiv=\"Content-Type\">
</head>
<body>
%s
</body>
</html>
"

let res =
  let file = In_channel.read_all Sys.argv.(1) in
  Sequme_doc_syntax.parse file
  >>= fun doc ->
  return (Sequme_doc_syntax.to_html ~map_section_levels:((+) 1) doc)
  >>| template
  >>= fun data ->
  Out_channel.write_all Sys.argv.(2) ~data;
  return ()
    
let () =
  match res with
  | Ok () -> ()
  | Error e ->
    begin match e with
    | `unknown_xml_tag t ->
      eprintf "unknown_xml_tag: %s\n%!" t
    | `xml_syntax_error ((x, y), err) ->
      eprintf "xml_syntax_error: %d, %d %s\n%!" x y Xmlm.(error_message err)
    | `unexpected_text t ->
      eprintf "unexpected_text: %S" t
    end;
    exit 2

