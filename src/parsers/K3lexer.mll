{   
open K3parser   
open Lexing   

let init_line lexbuf =
    let pos = lexbuf.Lexing.lex_curr_p in
        lexbuf.Lexing.lex_curr_p <- { pos with
            Lexing.pos_lnum = 1;
            Lexing.pos_bol = 0;
        }

let advance_line lexbuf =
    let pos = lexbuf.Lexing.lex_curr_p in
        lexbuf.Lexing.lex_curr_p <- { pos with
            Lexing.pos_lnum = pos.Lexing.pos_lnum + 1;
            Lexing.pos_bol = pos.Lexing.pos_cnum;
        }

let hashtbl_of_pair_list h l =
    List.iter (fun (p1, p2) -> Hashtbl.add h p1 p2) l

let keyword_table = Hashtbl.create 35
let keywords =   
   [   
         "ON", ON;
         "SYSTEM", SYSTEM;
         "READY", READY;
         "QUERY", QUERY;
         "IF", IF;
         "ELSE", ELSE;
         "IF0", IF0;
         "ITERATE", ITERATE;
         "LAMBDA", LAMBDA;
         "APPLY", APPLY;
         "MAP", MAP;
         "FLATTEN", FLATTEN;
         "AGGREGATE", AGGREGATE;
         "GROUPBYAGGREGATE", GROUPBYAGGREGATE;
         "MEMBER", MEMBER;
         "LOOKUP", LOOKUP;
         "SLICE", SLICE;
         "FILTER", FILTER;
         "PCUPDATE", PCUPDATE;
         "PCVALUEUPDATE", PCVALUEUPDATE;
         "PCELEMENTREMOVE", PCELEMENTREMOVE;
         "INT", INT;
         "UNIT", UNIT;
         "FLOAT", FLOAT;
         "COLLECTION", COLLECTION;
         "IN", IN;
         "OUT", OUT;
         "SINGLETON", SINGLETON;
         "COMBINE", COMBINE;
      
         "CREATE", CREATE;
         "TABLE", TABLE;
         "STREAM", STREAM;
         "FROM", FROM;
         "SOCKET", SOCKET;
         "FILE", FILE;
         "PIPE", PIPE;
         "FIXEDWIDTH", FIXEDWIDTH;
         "DELIMITED", DELIMITED;
         "LINE", LINE;
         "VARSIZE", VARSIZE;
         "OFFSET", OFFSET;
         "ADJUSTBY", ADJUSTBY;
         "VARCHAR",    VARCHAR;
         "CHAR",       CHAR;
         "DATE",       DATE;
         "STRING", STRINGTYPE;
         "INTEGER", TYPE(Type.TInt);
         "DOUBLE", TYPE(Type.TFloat);
         "DECIMAL", TYPE(Type.TFloat);
         "EXTERNALLAMBDA", EXTERNALLAMBDA;
   ]
let _ = hashtbl_of_pair_list keyword_table keywords

let ops_table = Hashtbl.create 11
let ops =
    [   
        "==",   EQ;
        "!=",   NE;
        "<",    LT;   
        "<=",   LE;  
        "+",    SUM;
        "*",    PRODUCT;
        ">",    GT;
        "-",    MINUS;
    ]
let _ = hashtbl_of_pair_list ops_table ops
    
}   
 
let char        = ['a'-'z' 'A'-'Z']   
let digit       = ['0'-'9']   
let decint      = digit+
let int         = ('-')?decint
let decimal     = digit+ '.' digit+
let number      = ('-'|'+')?digit+ '.' digit*
let float       = (int|decimal)'E'('+'|'-')?digit+
let identifier  = (char|('_'+(digit|char)))(char|digit|'_')*
let whitespace  = [' ' '\t']   
let newline     = "\n\r" | '\n' | '\r'  
let cmp_op      = "<" | "<=" | "==" | "!=" | '>'
let arith_op    = '+' | '*' | '-'
let strconst    = ('\"'[^'\"']*'\"') | ('\''[^'\'']*'\'')
let singlecm    = "--"[^'\n' '\r']*
let multicmst   = "/*"
let multicmend  = "*/"


rule tokenize = parse
| whitespace    { tokenize lexbuf }   
| newline       { advance_line lexbuf; tokenize lexbuf }
| int           { INTEGER(int_of_string (lexeme lexbuf)) }
| number        { CONST_FLOAT(float_of_string (lexeme lexbuf))  }
| "=>"          { BOUND }
| "->"          { ARROW }
| ":="          { SETVALUE }
| cmp_op
| arith_op      { let op_str = lexeme lexbuf in
                      try Hashtbl.find ops_table op_str
                      with Not_found -> 
                          raise (Failure ("unknown operator "^(op_str)))
                }
| identifier    { 
                  let keyword_str = lexeme lexbuf in
                  let keyword_str_uc = String.uppercase_ascii keyword_str in
                      try Hashtbl.find keyword_table keyword_str_uc
                      with Not_found -> ID(keyword_str)
                }
| strconst      { let s = lexeme lexbuf in 
                      CONST_STRING(String.sub s 1 ((String.length s)-2)) 
                }
| ','           { COMMA }
| '('           { LPAREN }
| ')'           { RPAREN }
| '['           { LBRACK }
| ']'           { RBRACK }
| '{'           { LBRACE }
| '}'           { RBRACE }
| ';'           { EOSTMT }
| ':'           { COLON }
| '$'           { DOLLAR }
| singlecm      { tokenize lexbuf}
| multicmst     { comment 1 lexbuf }
| eof           { EOF }

and comment depth = parse
| multicmst     { raise (Failure ("nested comments are invalid")) }
| multicmend    { tokenize lexbuf }
| eof           { raise (Failure ("hit end of file in a comment")) }
| _             { comment depth lexbuf }
