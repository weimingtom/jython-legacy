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
    ASTLabelType=PythonTree;
    output=AST;
}

tokens {
    INDENT;
    DEDENT;
    
    Module;
    Test;
    Msg;
    Import;
    ImportFrom;
    Name;
    Body;
    ClassDef;
    Bases; 
    FunctionDef;
    Arguments;
    Args;
    Arg;
    Keyword;
    StarArgs;
    KWArgs;
    Assign;
    AugAssign;
    Compare;
    Expr;
    Tuple;
    List;
    Dict;
    If;
    OrElse;
    Elif;
    While; 
    Pass;
    Break;
    Continue;
    Print;
    TryExcept;
    TryFinally;
    ExceptHandler;
    For;
    Return;
    Yield;
    Str;
    Num;
    IsNot;
    In;
    NotIn;
    Raise;
    Type;
    Inst;
    Tback;
    Global;
    Exec;
    Globals;
    Locals;
    Assert;
    Ellipsis;
    Comprehension;
    ListComp;
    Lambda;
    Repr;
    BinOp;
    Subscript;
    SubscriptList;
    Target;
    Targets;
    Value;
    Start;
    End;
    SliceOp;
    UnaryOp;
    UAdd;
    USub;
    Invert;
    Delete;
    Default;
    Alias;
    Asname;
    Decorator;
    Decorators;
    With;
    GenExpFor;
    Id;
    Iter;
    Ifs;
    Elts;
    Ctx;
    Attr;
    Call;
    Dest;
    Values;
    Newline;
    //The tokens below are not represented in the 2.5 Python.asdl
    GenFor;
    GenIf;
    ListFor;
    ListIf;
    FinalBody;
}

@header { 
package org.python.antlr;

import org.python.antlr.PythonTree;
} 

@members {
    boolean debugOn = false;

    private void debug(String message) {
        if (debugOn) {
            System.out.println(message);
        }
    }

    /**
     * A list holding the error message(s) encountered during parse.
     */
    private List<String> _errors = new ArrayList<String>();

    /**
     * @return <code>true</code> if the parser collected one or more error messages,
     *         <code>false</code> otherwise.
     */
    public boolean hasErrors() {
      return getErrors().size() > 0;
    }

    /**
     * @return A list of the error message(s) collected during parse.
     */
    public List<String> getErrors() {
        return _errors;
    }

    /**
     * Overridden to be able to collect error messages.
     * <p>
     * Since we do not want to lose the recovery mechanism and the verbose messages.
     */
    @Override
    public void emitErrorMessage(String msg) {
       super.emitErrorMessage(msg);
       getErrors().add(msg);
    }
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
file_input : (NEWLINE | stmt)* {debug("parsed file_input");}
          -> ^(Module stmt*)
           ;

//eval_input: testlist NEWLINE* ENDMARKER
eval_input : (NEWLINE!)* testlist (NEWLINE!)*
           ;

//decorators: decorator+
decorators: decorator+
          ;

//decorator: '@' dotted_name [ '(' [arglist] ')' ] NEWLINE
decorator: AT dotted_attr (LPAREN arglist? RPAREN)? NEWLINE
        -> ^(Decorator dotted_attr ^(Call arglist)?)
         ;

dotted_attr
    : NAME (DOT^ NAME)*
    ;

//funcdef: [decorators] 'def' NAME parameters ':' suite
funcdef : decorators? 'def' NAME parameters COLON suite
       -> ^(FunctionDef ^(Name NAME) ^(Arguments parameters) ^(Body suite) ^(Decorators decorators?))
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
           -> ^(Args defparameter+) ^(StarArgs $starargs)? ^(KWArgs $kwargs)?
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
     | compound_stmt
     ;

//simple_stmt: small_stmt (';' small_stmt)* [';'] NEWLINE
simple_stmt : small_stmt (options {greedy=true;}:SEMI small_stmt)* (SEMI)? NEWLINE
           -> small_stmt+
            ;

//small_stmt: expr_stmt | print_stmt  | del_stmt | pass_stmt | flow_stmt | import_stmt | global_stmt | exec_stmt | assert_stmt
small_stmt : expr_stmt
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
            ( (augassign yield_expr -> ^(augassign $lhs yield_expr))
            | (augassign rhs=testlist -> ^(augassign $lhs $rhs))
            | ((assigns) -> ^(Assign ^(Target $lhs) assigns))
            | -> $lhs
            )
          ;

//not in CPython's Grammar file
assigns : assign_testlist+
        | assign_yield+
        ;

//not in CPython's Grammar file
assign_testlist : (ASSIGN testlist ASSIGN) => ASSIGN testlist -> ^(Target testlist)
       | ASSIGN testlist -> ^(Value testlist)
       ;

//not in CPython's Grammar file
assign_yield : (ASSIGN yield_expr ASSIGN) => ASSIGN yield_expr -> ^(Target yield_expr)
       | ASSIGN yield_expr -> ^(Value yield_expr)
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
             ( t1=testlist -> {$t1.newline}? ^(Print ^(Values $t1) ^(Newline))
                           -> ^(Print ^(Values $t1))
             | RIGHTSHIFT t2=testlist -> {$t2.newline}? ^(Print ^(Dest RIGHTSHIFT) ^(Values testlist) ^(Newline))
                                      -> ^(Print ^(Dest RIGHTSHIFT) ^(Values testlist))
             | -> Print
             )
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
          -> Break
           ;

//continue_stmt: 'continue'
continue_stmt : 'continue'
             -> Continue
              ;

//return_stmt: 'return' [testlist]
return_stmt : 'return' (testlist)?
          -> ^(Return ^(Value testlist)?)
            ;

//yield_stmt: yield_expr
yield_stmt : yield_expr
           ;

//raise_stmt: 'raise' [test [',' test [',' test]]]
raise_stmt: 'raise' (t1=test (COMMA t2=test (COMMA t3=test)?)?)?
          -> ^(Raise ^(Type $t1)? ^(Inst $t2)? ^(Tback $t3)?)
          ;

//import_stmt: import_name | import_from
import_stmt : import_name
            | import_from
            ;

//import_name: 'import' dotted_as_names
import_name : 'import' dotted_as_names
           -> ^(Import dotted_as_names)
            ;

//XXX: needs work?
//import_from: ('from' ('.'* dotted_name | '.'+)
//              'import' ('*' | '(' import_as_names ')' | import_as_names))
import_from: 'from' (DOT* dotted_name | DOT+) 'import'
              (STAR
             -> ^(ImportFrom dotted_name ^(Import STAR))
              | import_as_names
             -> ^(ImportFrom dotted_name ^(Import import_as_names))
              | LPAREN import_as_names RPAREN
             -> ^(ImportFrom dotted_name ^(Import import_as_names))
              )
           ;

//import_as_name: NAME [('as' | NAME) NAME]
import_as_name : name=NAME ('as' asname=NAME)?
              -> ^(Alias $name ^(Asname $asname)?)
               ;

//dotted_as_name: dotted_name [('as' | NAME) NAME]
dotted_as_name : dotted_name ('as' asname=NAME)?
              -> ^(Alias dotted_name ^(Asname NAME)?)
               ;

//import_as_names: import_as_name (',' import_as_name)* [',']
import_as_names : import_as_name (COMMA! import_as_name)* (COMMA!)?
                ;

//dotted_as_names: dotted_as_name (',' dotted_as_name)*
dotted_as_names : dotted_as_name (COMMA! dotted_as_name)*
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
              | with_stmt
              | funcdef
              | classdef
              ;

//if_stmt: 'if' test ':' suite ('elif' test ':' suite)* ['else' ':' suite]
if_stmt: 'if' test COLON ifsuite=suite elif_clause*  ('else' COLON elsesuite=suite)?
      -> ^(If test $ifsuite elif_clause* ^(OrElse $elsesuite)?)
       ;

//not in CPython's Grammar file
elif_clause : 'elif' test COLON suite
           -> ^(Elif test suite)
            ;

//while_stmt: 'while' test ':' suite ['else' ':' suite]
while_stmt : 'while' test COLON s1=suite ('else' COLON s2=suite)?
          -> ^(While test ^(Body $s1) ^(OrElse $s2)?)
           ;

//for_stmt: 'for' exprlist 'in' testlist ':' suite ['else' ':' suite]
for_stmt : 'for' exprlist 'in' testlist COLON s1=suite ('else' COLON s2=suite)?
        -> ^(For ^(Target exprlist) ^(Iter testlist) ^(Body $s1) ^(OrElse $s2)?)
         ;

//try_stmt: ('try' ':' suite
//           ((except_clause ':' suite)+
//	    ['else' ':' suite]
//	    ['finally' ':' suite] |
//	   'finally' ':' suite))
try_stmt : 'try' COLON trysuite=suite
           ( (except_clause+ ('else' COLON elsesuite=suite)? ('finally' COLON finalsuite=suite)?
          -> ^(TryExcept ^(Body $trysuite) except_clause+ ^(OrElse $elsesuite)? ^(FinalBody 'finally' $finalsuite)?))
           | ('finally' COLON finalsuite=suite
          -> ^(TryFinally ^(Body $trysuite) ^(FinalBody $finalsuite)))
           )
         ;

//with_stmt: 'with' test [ with_var ] ':' suite
with_stmt: 'with' test (with_var)? COLON suite
        -> ^(With test with_var? ^(Body suite))
         ;

//with_var: ('as' | NAME) expr
with_var: ('as' | NAME) expr
        ;

//except_clause: 'except' [test [',' test]]
except_clause : 'except' (t1=test (COMMA t2=test)?)? COLON suite
             -> ^(ExceptHandler ^(Type $t1)? ^(Name $t2)? ^(Body suite))
              ;

//suite: simple_stmt | NEWLINE INDENT stmt+ DEDENT
suite : simple_stmt
      | NEWLINE! INDENT (stmt)+ DEDENT
      ;

//FIXME: looks like this one is going to be tough.
//test: or_test ['if' or_test 'else' test] | lambdef
test: or_test //('if' test 'else' test)?
    | lambdef {debug("parsed lambdef");}
    ;

//or_test: and_test ('or' and_test)*
or_test : and_test ('or'^ and_test)*
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
factor : PLUS factor -> ^(UAdd factor)
       | MINUS factor -> ^(USub factor)
       | TILDE factor -> ^(Invert factor)
       | power
       ;

//power: atom trailer* ['**' factor]
power : atom (trailer^)* (options {greedy=true;}:DOUBLESTAR^ factor)?
      ;

//atom: '(' [testlist] ')' | '[' [listmaker] ']' | '{' [dictmaker] '}' | '`' testlist1 '`' | NAME | NUMBER | STRING+
atom : LPAREN 
       //XXX: calling all of these "Tuple" is almost certainly incorrect.
       ( yield_expr    -> ^(Tuple ^(Elts yield_expr))
       | testlist_gexp {debug("parsed testlist_gexp");} -> ^(Tuple ^(Elts testlist_gexp))
       | -> ^(Tuple)
       )
       RPAREN
     | LBRACK (listmaker)? RBRACK -> ^(List ^(Elts listmaker)?)
     | LCURLY (dictmaker)? RCURLY -> ^(Dict dictmaker?)
     | BACKQUOTE testlist BACKQUOTE -> ^(Repr testlist)
     | NAME {debug("parsed NAME");} -> ^(Name NAME)
     | INT -> ^(Num INT)
     | LONGINT -> ^(Num LONGINT)
     | FLOAT -> ^(Num FLOAT)
     | COMPLEX -> ^(Num COMPLEX)
     | (STRING)+ -> ^(Str STRING+)
     ;

//listmaker: test ( list_for | (',' test)* [','] )
listmaker : test 
            ( list_for -> ^(ListComp list_for)
            | (options {greedy=true;}:COMMA test)* -> test+
            ) (COMMA)?
          ;

//testlist_gexp: test ( gen_for | (',' test)* [','] )
testlist_gexp : test ( gen_for -> ^(GenExpFor gen_for)
                     | (options {k=2;}: COMMA test)* -> test+
                     )
                     (COMMA)?
              ;

//FIXME: switched to or_test for now which allows simple lambdas to work - but
//      this prevents nested lambdas. see test_scope.py for examples that fail.
//lambdef: 'lambda' [varargslist] ':' test
lambdef: 'lambda' (varargslist)? COLON or_test {debug("parsed lambda");}
      -> ^(Lambda varargslist? ^(Body or_test))
       ;

//trailer: '(' [arglist] ')' | '[' subscriptlist ']' | '.' NAME
trailer : LPAREN (arglist)? RPAREN -> ^(Call ^(Args arglist)?)
        | LBRACK subscriptlist RBRACK -> ^(SubscriptList subscriptlist)
        | DOT^ NAME {debug("motched DOT^ NAME");}
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
exprlist : (expr COMMA) => expr (options {k=2;}: COMMA expr)* (COMMA)? -> ^(Tuple ^(Elts expr+))
         | expr
         ;

//testlist: test (',' test)* [',']
//XXX: newline is only used by print - is there a better way?
testlist returns [boolean newline]
    : (test COMMA) => test (options {k=2;}: COMMA test)* (trailcomma=COMMA)?
    { if ($trailcomma == null) {
          $newline = true;
      } else {
          $newline = false;
      }
    }
   -> ^(Tuple ^(Elts test+))
    | test {$newline = true;}
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
       -> ^(Args argument+) ^(StarArgs $starargs)? ^(KWArgs $kwargs)?
        |   STAR starargs=test (COMMA DOUBLESTAR kwargs=test)?
       -> ^(StarArgs $starargs) ^(KWArgs $kwargs)?
        |   DOUBLESTAR kwargs=test
       -> ^(KWArgs $kwargs)
        ;

//argument: [test '='] test	// Really [keyword '='] test
argument : t1=test
         ( (ASSIGN t2=test) -> ^(Keyword ^(Arg $t1) ^(Value $t2)?)
         | gen_for -> ^(GenFor $t1 gen_for)
         | -> ^(Arg $t1)
         )
         ;

//list_iter: list_for | list_if
list_iter : list_for
          | list_if
          ;

//list_for: 'for' exprlist 'in' testlist_safe [list_iter]
list_for : 'for' exprlist 'in' testlist (list_iter)?
        -> ^(ListFor ^(Target exprlist) ^(Iter testlist) ^(Ifs list_iter)?)
         ;

//list_if: 'if' test [list_iter]
list_if : 'if' test (list_iter)?
       -> ^(ListIf ^(Target test) (Ifs list_iter)?)
        ;

//gen_iter: gen_for | gen_if
gen_iter: gen_for
        | gen_if
        ;

//gen_for: 'for' exprlist 'in' or_test [gen_iter]
gen_for: 'for' exprlist 'in' or_test gen_iter?
      -> ^(GenFor ^(Target exprlist) ^(Iter gen_iter)?)
       ;

//gen_if: 'if' old_test [gen_iter]
gen_if: 'if' test gen_iter?
     -> ^(GenIf ^(Target test) ^(Iter gen_iter)?)
      ;

//yield_expr: 'yield' [testlist]
yield_expr : 'yield' testlist?
          -> ^(Yield ^(Value testlist)?)
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

AT : '@' ;

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

/* XXX: Just discarding form feeds -- Does python assign any meaning to formfeed?
      Since most of these where in the email package, I bet they have meaning as part
      of a string and are being used in email headers or some such.  If so I'll need
      to move this to STRING.
*/
FORMFEED : '\u000C' {$channel=HIDDEN;}
         ;
 
