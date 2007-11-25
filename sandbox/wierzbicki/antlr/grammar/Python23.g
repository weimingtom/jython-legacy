/*
 [The 'BSD licence']
 Copyright (c) 2004 Terence Parr and Loring Craymer
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/** Python 2.3.3 Grammar
 *
 *  Terence Parr and Loring Craymer
 *  February 2004
 *
 *  Converted to ANTLR v3 November 2005 by Terence Parr.
 *
 *  This grammar was derived automatically from the Python 2.3.3
 *  parser grammar to get a syntactically correct ANTLR grammar
 *  for Python.  Then Terence hand tweaked it to be semantically
 *  correct; i.e., removed lookahead issues etc...  It is LL(1)
 *  except for the (sometimes optional) trailing commas and semi-colons.
 *  It needs two symbols of lookahead in this case.
 *
 *  Starting with Loring's preliminary lexer for Python, I modified it
 *  to do my version of the whole nasty INDENT/DEDENT issue just so I
 *  could understand the problem better.  This grammar requires
 *  PythonTokenStream.java to work.  Also I used some rules from the
 *  semi-formal grammar on the web for Python (automatically
 *  translated to ANTLR format by an ANTLR grammar, naturally <grin>).
 *  The lexical rules for python are particularly nasty and it took me
 *  a long time to get it 'right'; i.e., think about it in the proper
 *  way.  Resist changing the lexer unless you've used ANTLR a lot. ;)
 *
 *  I (Terence) tested this by running it on the jython-2.1/Lib
 *  directory of 40k lines of Python.
 *
 *  REQUIRES ANTLR v3
 *
 *
 *  Baby step towards an antlr based Jython parser.
 *  Terence's Lexer is intact pretty much unchanged, the parser has
 *  been altered to produce an AST - the AST work started from tne newcompiler
 *  grammar from Jim Baker minus post-2.3 features.  The current parsing
 *  and compiling strategy looks like this:
 *
 *  Python source->Python.g->simple antlr AST->PythonWalker.g->
 *  decorated AST (org/python/parser/ast/*)->CodeCompiler(ASM)->.class
 *
 *  for a very limited set of functionality.
 */

grammar Python;
options {
    output=AST;
}

tokens {
    INDENT;
    DEDENT;
    
    Test;
    Msg;
    Stmt;
    Import;
    ImportFrom;
    Name;
    Body;
    ClassDef;
    Bases; 
    FunctionDef;
    Args;
    StarArgs;
    KWArgs;
    Arg;
    Arguments;
    Assign;
    Compare;
    Expr;
    ExprList;
    Tuple;
    List;
    Dict;
    If;
    Else;
    Elif;
    While; 
    Pass;
    Print;
    TryExcept;
    TryFinally;
    Except;
    For;
    Return;
    Yield;
    String;
    IsNot;
    In;
    NotIn;
    Raise;
    Type;
    Inst;
    Tback;
    Global;
    Exec;Globals;Locals;
    Assert;
    Ellipsis;
    ListComp;
    Lambda;
    Repr;
    BinOp;
    ArgList;
    Subscript;
    SubscriptList;
    Targets;
    Values;
    Start;
    End;
    SliceOp;
    UnaryPlus;
    UnaryMinus;
    UnaryTilde;
    Delete;
    Default;
    Alias;
    Asname;
}

@header { 
package org.python.antlr;
} 

@lexer::header { 
package org.python.antlr;
} 

@lexer::members {
/** Handles context-sensitive lexing of implicit line joining such as
 *  the case where newline is ignored in cases like this:
 *  a = [3,
 *       4]
 */
int implicitLineJoiningLevel = 0;
int startPos=-1;
}

//single_input: NEWLINE | simple_stmt | compound_stmt NEWLINE
single_input : NEWLINE!
             | simple_stmt
             | compound_stmt NEWLINE!
             ;

//file_input: (NEWLINE | stmt)* ENDMARKER
file_input : (NEWLINE! | stmt)*
           ;

//eval_input: testlist NEWLINE* ENDMARKER
eval_input : (NEWLINE!)* testlist (NEWLINE!)*
           ;

//funcdef: 'def' NAME parameters ':' suite
funcdef : 'def' NAME parameters COLON suite
       -> ^(FunctionDef ^(Name NAME) ^(Args parameters) ^(Body suite))
        ;

//parameters: '(' [varargslist] ')'
parameters : LPAREN (varargslist)? RPAREN
          -> (varargslist)?
           ;

//varargslist: (fpdef ['=' test] ',')* ('*' NAME [',' '**' NAME] | '**' NAME) | fpdef ['=' test] (',' fpdef ['=' test])* [',']
varargslist : defparameter (options {greedy=true;}:COMMA defparameter)*
              (COMMA
                  ( STAR starargs=NAME (COMMA DOUBLESTAR kwargs=NAME)?
                  | DOUBLESTAR kwargs=NAME
                  )?
              )?
           -> ^(Arguments defparameter+) ^(StarArgs $starargs)? ^(KWArgs $kwargs)?
            | STAR starargs=NAME (COMMA DOUBLESTAR kwargs=NAME)?
           -> ^(StarArgs $starargs) ^(KWArgs $kwargs)?
            | DOUBLESTAR kwargs=NAME
           -> ^(KWArgs $kwargs)
            ;

//not in CPython's Grammar file
defparameter : fpdef (ASSIGN test)?
             ;

//fpdef: NAME | '(' fplist ')'
fpdef : NAME
      | LPAREN! fplist RPAREN!
      ;

//fplist: fpdef (',' fpdef)* [',']
fplist : fpdef (options {greedy=true;}:COMMA fpdef)* (COMMA)?
      -> fpdef+
       ;

//stmt: simple_stmt | compound_stmt
stmt : simple_stmt
    -> ^(Stmt simple_stmt)
     | compound_stmt
    -> ^(Stmt compound_stmt)
     ;

//simple_stmt: small_stmt (';' small_stmt)* [';'] NEWLINE
simple_stmt : small_stmt (options {greedy=true;}:SEMI small_stmt)* (SEMI)? NEWLINE
           -> small_stmt+
            ;

//small_stmt: expr_stmt | print_stmt  | del_stmt | pass_stmt | flow_stmt | import_stmt | global_stmt | exec_stmt | assert_stmt
small_stmt : expr_stmt -> ^(Expr expr_stmt)
           | print_stmt
           | del_stmt
           | pass_stmt
           | flow_stmt
           | import_stmt
           | global_stmt
           | exec_stmt
           | assert_stmt
           ;

//expr_stmt: testlist (augassign testlist | ('=' testlist)*)
expr_stmt : lhs=testlist
            ( (augassign rhs=testlist -> ^(augassign $lhs $rhs))
            | ((ASSIGN rhs=testlist)+ -> ^(Assign ^(Targets $lhs) ^(Values $rhs)))
            | -> $lhs
            )
          ;

//augassign: '+=' | '-=' | '*=' | '/=' | '%=' | '&=' | '|=' | '^=' | '<<=' | '>>=' | '**=' | '//='
augassign : PLUSEQUAL
          | MINUSEQUAL
          | STAREQUAL
          | SLASHEQUAL
          | PERCENTEQUAL
          | AMPEREQUAL
          | VBAREQUAL
          | CIRCUMFLEXEQUAL
          | LEFTSHIFTEQUAL
          | RIGHTSHIFTEQUAL
          | DOUBLESTAREQUAL
          | DOUBLESLASHEQUAL
          ;

//print_stmt: 'print' ( [ test (',' test)* [','] ] | '>>' test [ (',' test)+ [','] ] )
print_stmt : 'print'
             ( testlist
             | RIGHTSHIFT testlist
             )?
          -> ^(Print RIGHTSHIFT? testlist?)
           ;

//del_stmt: 'del' exprlist
del_stmt : 'del' exprlist
        -> ^(Delete exprlist)
         ;

//pass_stmt: 'pass'
pass_stmt : 'pass'
         -> Pass
          ;

//flow_stmt: break_stmt | continue_stmt | return_stmt | raise_stmt | yield_stmt
flow_stmt : break_stmt
          | continue_stmt
          | return_stmt
          | raise_stmt
          | yield_stmt
          ;

//break_stmt: 'break'
break_stmt : 'break'
           ;

//continue_stmt: 'continue'
continue_stmt : 'continue'
              ;

//return_stmt: 'return' [testlist]
return_stmt : 'return' (testlist)?
          -> ^(Return testlist?)
            ;

//yield_stmt: 'yield' testlist
yield_stmt : 'yield' testlist
          -> ^(Yield testlist)
           ;

//raise_stmt: 'raise' [test [',' test [',' test]]]
raise_stmt: 'raise' (t1=test (COMMA t2=test (COMMA t3=test)?)?)?
          -> ^(Raise ^(Type $t1)? ^(Inst $t2)? ^(Tback $t3)?)
          ;

//import_stmt: 'import' dotted_as_name (',' dotted_as_name)* | 'from' dotted_name 'import' ('*' | import_as_name (',' import_as_name)*)
import_stmt : 'import' dotted_as_name (COMMA dotted_as_name)*
           -> ^(Import dotted_as_name+)
            | 'from' dotted_name 'import'
              (STAR
             -> ^(ImportFrom dotted_name ^(Import STAR))
              | import_as_name (COMMA import_as_name)*
             -> ^(ImportFrom dotted_name ^(Import import_as_name+))
              )
            ;

//import_as_name: NAME [NAME NAME]
import_as_name : name=NAME ('as' asname=NAME)?
              -> ^(Alias $name ^(Asname $asname)?)
               ;

//dotted_as_name: dotted_name [NAME NAME]
dotted_as_name : dotted_name ('as' asname=NAME)?
              -> ^(Alias dotted_name ^(Asname NAME)?)
               ;

//dotted_name: NAME ('.' NAME)*
dotted_name : NAME (DOT NAME)*
            ;

//global_stmt: 'global' NAME (',' NAME)*
global_stmt : 'global' NAME (COMMA NAME)*
           -> ^(Global NAME+)
            ;

//exec_stmt: 'exec' expr ['in' test [',' test]]
exec_stmt : 'exec' expr ('in' t1=test (COMMA t2=test)?)?
         -> ^(Exec expr ^(Globals $t1)? ^(Locals $t2)?)
          ;

//assert_stmt: 'assert' test [',' test]
assert_stmt : 'assert' t1=test (COMMA t2=test)?
           -> ^(Assert ^(Test $t1) ^(Msg $t2)?)
            ;

//compound_stmt: if_stmt | while_stmt | for_stmt | try_stmt | funcdef | classdef
compound_stmt : if_stmt
              | while_stmt
              | for_stmt
              | try_stmt
              | funcdef
              | classdef
              ;

//if_stmt: 'if' test ':' suite ('elif' test ':' suite)* ['else' ':' suite]
if_stmt: 'if' test COLON ifsuite=suite elif_clause*  ('else' COLON elsesuite=suite)?
      -> ^(If test $ifsuite elif_clause* ^(Else $elsesuite)?)
       ;

//not in CPython's Grammar file
elif_clause : 'elif' test COLON suite
           -> ^(Elif test suite)
            ;

//while_stmt: 'while' test ':' suite ['else' ':' suite]
while_stmt : 'while' test COLON s1=suite ('else' COLON s2=suite)?
          -> ^(While test ^(Body $s1) ^(Else $s2)?)
           ;

//for_stmt: 'for' exprlist 'in' testlist ':' suite ['else' ':' suite]
for_stmt : 'for' exprlist 'in' testlist COLON s1=suite ('else' COLON s2=suite)?
        -> ^(For exprlist ^(In testlist) ^(Body $s1) ^(Else $s2)?)
         ;

//try_stmt: ('try' ':' suite (except_clause ':' suite)+ #diagram:break
//           ['else' ':' suite] | 'try' ':' suite 'finally' ':' suite)
try_stmt : 'try' COLON trysuite=suite
           ( (except_clause+ ('else' COLON elsesuite=suite)?
          -> ^(TryExcept ^(Body $trysuite) except_clause+ ^(Else $elsesuite)?))
           | ('finally' COLON suite
          -> ^(TryFinally suite))
           )
         ;

//except_clause: 'except' [test [',' test]]
except_clause : 'except' (t1=test (COMMA t2=test)?)? COLON suite
             -> ^(Except ^(Type $t1)? ^(Name $t2)? ^(Body suite))
              ;

//suite: simple_stmt | NEWLINE INDENT stmt+ DEDENT
suite : simple_stmt -> ^(Stmt simple_stmt)
      | NEWLINE! INDENT (stmt)+ DEDENT
      ;

//test: and_test ('or' and_test)* | lambdef
test : and_test ('or'^ and_test)*
     | lambdef
     ;

//and_test: not_test ('and' not_test)*
and_test : not_test ('and'^ not_test)*
         ;

//not_test: 'not' not_test | comparison
not_test : 'not'^ not_test
         | comparison
         ;

//comparison: expr (comp_op expr)*
comparison: expr (comp_op^ expr)*
	;

//comparison : expr
//             ( ((comp_op expr)+ -> ^(Compare expr (comp_op expr)+))
//             | expr
//             )
//	       ;

//comp_op: '<'|'>'|'=='|'>='|'<='|'<>'|'!='|'in'|'not' 'in'|'is'|'is' 'not'
comp_op : LESS
        | GREATER
        | EQUAL
        | GREATEREQUAL
        | LESSEQUAL
        | ALT_NOTEQUAL
        | NOTEQUAL
        | 'in'
        | 'not' 'in' -> NotIn
        | 'is'
        | 'is' 'not' -> IsNot
        ;

//expr: xor_expr ('|' xor_expr)*
expr : xor_expr (VBAR^ xor_expr)*
     ;

//xor_expr: and_expr ('^' and_expr)*
xor_expr : and_expr (CIRCUMFLEX^ and_expr)*
         ;

//and_expr: shift_expr ('&' shift_expr)*
and_expr : shift_expr (AMPER^ shift_expr)*
         ;

//shift_expr: arith_expr (('<<'|'>>') arith_expr)*
shift_expr : arith_expr ((LEFTSHIFT^|RIGHTSHIFT^) arith_expr)*
           ;

//arith_expr : lhs=term 
//             ( ((PLUS) term)+ -> ^(PLUS $lhs term+)
//             | ((MINUS) term)+ -> ^(MINUS $lhs term+)
//             | -> ^(Expr $lhs)
//             )
//           ;


//arith_expr: term (('+'|'-') term)*
arith_expr: term ((PLUS^|MINUS^) term)*
	;

//term: factor (('*'|'/'|'%'|'//') factor)*
term : factor ((STAR^ | SLASH^ | PERCENT^ | DOUBLESLASH^ ) factor)*
     ;

//factor: ('+'|'-'|'~') factor | power
factor : PLUS factor -> ^(UnaryPlus factor)
       | MINUS factor -> ^(UnaryMinus factor)
       | TILDE factor -> ^(UnaryTilde factor)
       | power
       ;

//power: atom trailer* ['**' factor]
power : atom (trailer)* (options {greedy=true;}:DOUBLESTAR^ factor)?
      ;

//atom: '(' [testlist] ')' | '[' [listmaker] ']' | '{' [dictmaker] '}' | '`' testlist1 '`' | NAME | NUMBER | STRING+
atom : LPAREN (testlist)? RPAREN -> ^(Tuple testlist?)
     | LBRACK (listmaker)? RBRACK -> ^(List listmaker?)
     | LCURLY (dictmaker)? RCURLY -> ^(Dict dictmaker?)
     | BACKQUOTE testlist BACKQUOTE -> ^(Repr testlist)
     | NAME
     | INT
     | LONGINT
     | FLOAT
     | COMPLEX
     | (STRING)+ -> ^(String STRING+)
     ;

//listmaker: test ( list_for | (',' test)* [','] )
listmaker : test 
            ( list_for -> ^(ListComp list_for)
            | (options {greedy=true;}:COMMA test)* -> test+
            ) (COMMA)?
          ;

//lambdef: 'lambda' [varargslist] ':' test
lambdef: 'lambda' (varargslist)? COLON test
      -> ^(Lambda varargslist? ^(Body test))
       ;

//trailer: '(' [arglist] ')' | '[' subscriptlist ']' | '.' NAME
trailer : LPAREN (arglist)? RPAREN -> ^(ArgList arglist?)
        | LBRACK subscriptlist RBRACK -> ^(SubscriptList subscriptlist)
        | DOT NAME
        ;

//subscriptlist: subscript (',' subscript)* [',']
subscriptlist : subscript (options {greedy=true;}:COMMA subscript)* (COMMA)?
             -> subscript+
              ;

//subscript: '.' '.' '.' | test | [test] ':' [test] [sliceop]
subscript : DOT DOT DOT -> Ellipsis
          | t1=test (COLON (t2=test)? (sliceop)?)? -> ^(Subscript ^(Start $t1) ^(End $t2)? ^(SliceOp sliceop)?)
          | COLON (test)? (sliceop)? -> ^(Subscript ^(End test)? ^(SliceOp sliceop)?)
          ;

//sliceop: ':' [test]
sliceop : COLON (test)? -> test?
        ;

//exprlist: expr (',' expr)* [',']
exprlist : expr (options {k=2;}: COMMA expr)* (COMMA)?
        -> ^(ExprList expr+)
         ;

//testlist: test (',' test)* [',']
testlist : test (options {k=2;}: COMMA test)* (COMMA)?
        -> test+
         ;

//XXX:
//testlist_safe: test [(',' test)+ [',']]

//dictmaker: test ':' test (',' test ':' test)* [',']
dictmaker : test COLON test
            (options {k=2;}:COMMA test COLON test)* (COMMA)?
         -> test+
          ;

//classdef: 'class' NAME ['(' testlist ')'] ':' suite
classdef: 'class' NAME (LPAREN testlist RPAREN)? COLON suite
    -> ^(ClassDef ^(Name NAME) ^(Bases testlist)? ^(Body suite))
    ;

//arglist: (argument ',')* (argument [',']| '*' test [',' '**' test] | '**' test)
arglist : argument (COMMA argument)*
          ( COMMA
            ( STAR starargs=test (COMMA DOUBLESTAR kwargs=test)?
            | DOUBLESTAR kwargs=test
            )?
          )?
       -> ^(Arguments argument+) ^(StarArgs $starargs)? ^(KWArgs $kwargs)?
        |   STAR starargs=test (COMMA DOUBLESTAR kwargs=test)?
       -> ^(StarArgs $starargs) ^(KWArgs $kwargs)?
        |   DOUBLESTAR kwargs=test
       -> ^(KWArgs $kwargs)
        ;

//argument: [test '='] test	// Really [keyword '='] test
argument : t1=test (ASSIGN t2=test)?
        -> ^(Arg $t1 ^(Default $t2)?)
         ;

//list_iter: list_for | list_if
list_iter : list_for
          | list_if
          ;

//list_for: 'for' exprlist 'in' testlist_safe [list_iter]
list_for : 'for' exprlist 'in' testlist (list_iter)?
         ;

//list_if: 'if' test [list_iter]
list_if : 'if' test (list_iter)?
        ;

//XXX:
//testlist1: test (',' test)*


LPAREN    : '(' {implicitLineJoiningLevel++;} ;

RPAREN    : ')' {implicitLineJoiningLevel--;} ;

LBRACK    : '[' {implicitLineJoiningLevel++;} ;

RBRACK    : ']' {implicitLineJoiningLevel--;} ;

COLON     : ':' ;

COMMA    : ',' ;

SEMI    : ';' ;

PLUS    : '+' ;

MINUS    : '-' ;

STAR    : '*' ;

SLASH    : '/' ;

VBAR    : '|' ;

AMPER    : '&' ;

LESS    : '<' ;

GREATER    : '>' ;

ASSIGN    : '=' ;

PERCENT    : '%' ;

BACKQUOTE    : '`' ;

LCURLY    : '{' {implicitLineJoiningLevel++;} ;

RCURLY    : '}' {implicitLineJoiningLevel--;} ;

CIRCUMFLEX    : '^' ;

TILDE    : '~' ;

EQUAL    : '==' ;

NOTEQUAL    : '!=' ;

ALT_NOTEQUAL: '<>' ;

LESSEQUAL    : '<=' ;

LEFTSHIFT    : '<<' ;

GREATEREQUAL    : '>=' ;

RIGHTSHIFT    : '>>' ;

PLUSEQUAL    : '+=' ;

MINUSEQUAL    : '-=' ;

DOUBLESTAR    : '**' ;

STAREQUAL    : '*=' ;

DOUBLESLASH    : '//' ;

SLASHEQUAL    : '/=' ;

VBAREQUAL    : '|=' ;

PERCENTEQUAL    : '%=' ;

AMPEREQUAL    : '&=' ;

CIRCUMFLEXEQUAL    : '^=' ;

LEFTSHIFTEQUAL    : '<<=' ;

RIGHTSHIFTEQUAL    : '>>=' ;

DOUBLESTAREQUAL    : '**=' ;

DOUBLESLASHEQUAL    : '//=' ;

DOT : '.' ;

FLOAT
    :    '.' DIGITS (Exponent)?
    |   DIGITS ('.' (DIGITS (Exponent)?)? | Exponent)
    ;

LONGINT
    :   INT ('l'|'L')
    ;

fragment
Exponent
    :    ('e' | 'E') ( '+' | '-' )? DIGITS
    ;

INT :   // Hex
        '0' ('x' | 'X') ( '0' .. '9' | 'a' .. 'f' | 'A' .. 'F' )+
    |   // Octal
        '0' DIGITS*
    |   '1'..'9' DIGITS*
    ;

COMPLEX
    :   INT ('j'|'J')
    |   FLOAT ('j'|'J')
    ;

fragment
DIGITS : ( '0' .. '9' )+ ;

NAME:    ( 'a' .. 'z' | 'A' .. 'Z' | '_')
        ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' )*
    ;

/** Match various string types.  Note that greedy=false implies '''
 *  should make us exit loop not continue.
 */
STRING
    :   ('r'|'u'|'ur')?
        (   '\'\'\'' (options {greedy=false;}:.)* '\'\'\''
        |   '"""' (options {greedy=false;}:.)* '"""'
        |   '"' (ESC|~('\\'|'\n'|'"'))* '"'
        |   '\'' (ESC|~('\\'|'\n'|'\''))* '\''
        )
    ;

fragment
ESC
    :    '\\' .
    ;

/** Consume a newline and any whitespace at start of next line */
CONTINUED_LINE
    :    '\\' ('\r')? '\n' (' '|'\t')* { $channel=HIDDEN; }
    ;

/** Treat a sequence of blank lines as a single blank line.  If
 *  nested within a (..), {..}, or [..], then ignore newlines.
 *  If the first newline starts in column one, they are to be ignored.
 */
NEWLINE
    :   (('\r')? '\n' )+
        {if ( startPos==0 || implicitLineJoiningLevel>0 )
            $channel=HIDDEN;
        }
    ;

WS    :    {startPos>0}?=> (' '|'\t')+ {$channel=HIDDEN;}
    ;
    
/** Grab everything before a real symbol.  Then if newline, kill it
 *  as this is a blank line.  If whitespace followed by comment, kill it
 *  as it's a comment on a line by itself.
 *
 *  Ignore leading whitespace when nested in [..], (..), {..}.
 */
LEADING_WS
@init {
    int spaces = 0;
}
    :   {startPos==0}?=>
        (   {implicitLineJoiningLevel>0}? ( ' ' | '\t' )+ {$channel=HIDDEN;}
           |    (     ' '  { spaces++; }
            |    '\t' { spaces += 8; spaces -= (spaces \% 8); }
               )+
            {
            // make a string of n spaces where n is column number - 1
            char[] indentation = new char[spaces];
            for (int i=0; i<spaces; i++) {
                indentation[i] = ' ';
            }
            String s = new String(indentation);
            emit(new ClassicToken(LEADING_WS,new String(indentation)));
            }
            // kill trailing newline if present and then ignore
            ( ('\r')? '\n' {if (token!=null) token.setChannel(HIDDEN); else $channel=HIDDEN;})*
           // {token.setChannel(99); }
        )
    ;

/** Comments not on line by themselves are turned into newlines.

    b = a # end of line comment

    or

    a = [1, # weird
         2]

    This rule is invoked directly by nextToken when the comment is in
    first column or when comment is on end of nonwhitespace line.

    Only match \n here if we didn't start on left edge; let NEWLINE return that.
    Kill if newlines if we live on a line by ourselves
    
    Consume any leading whitespace if it starts on left edge.
 */
COMMENT
@init {
    $channel=HIDDEN;
}
    :    {startPos==0}?=> (' '|'\t')* '#' (~'\n')* '\n'+
    |    {startPos>0}?=> '#' (~'\n')* // let NEWLINE handle \n unless char pos==0 for '#'
    ;