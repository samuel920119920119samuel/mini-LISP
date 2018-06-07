{
    var unroll = options.util.makeUnroll(location, options);
    var ast    = options.util.makeAST   (location, options);
}

PROGRAM
    = STMTS:STMT+ {
        //console.log("program");
        return ast("Program").add(STMTS);
    }

STMT
    = _* EXP:EXP _* {
        //console.log("exp to stmt");
        return EXP;
    }
    / _* DEF_STMT:DEF_STMT _* {
        //console.log("def to stmt");
        return DEF_STMT;
    }
    / _* PRINTSTMT:PRINTSTMT _* {
        //console.log("print to stmt");
        return PRINTSTMT;
    }

PRINTSTMT
    = _* "(" _* "print-num" _* EXP:EXP _* ")" _*{
        return ast("PrintNum").add(EXP);
    }
    /  _* "(" _* "print-bool" _* EXP:EXP _* ")" _*{
        return ast("PrintBool").add(EXP);
    }

EXP
    = _* bool_val:bool_val _*{
        //console.log("bool to exp");
        return bool_val;
    }
    / _* number:number _*{
        //console.log("num to exp");
        return number;
    }
    / _* VARIABLE:VARIABLE _*{
        //console.log("var to exp");
        return VARIABLE;
    }
    / _* NUM_OP:NUM_OP _* {
        //console.log("numop to exp");
        return NUM_OP;
    }
    / _* LOGICAL_OP:LOGICAL_OP _* {
        return LOGICAL_OP;
    }
    / _* FUN_EXP:FUN_EXP _* {
        //console.log("fun_exp to exp");
        return FUN_EXP;
    }
    / _* FUN_CALL:FUN_CALL _* {
        return FUN_CALL;
    }
    / _* IF_EXP:IF_EXP _* {
        //console.log("if_exp to exp");
        return IF_EXP;
    }

NUM_OP
    = PLUS     :  _* "(" _* "+" _* EXP1:EXP _* EXP2:EXP+ _* ")" _* {
        //console.log("plus");
        return ast("Plus").add(EXP1,EXP2);
    }
    / MINUS    :  _* "(" _* "-" _* EXP1:EXP _* EXP2:EXP ")" _* {
        return ast("Minus").add(EXP1,EXP2);
    }
    / MULTIPLY : _* "(" _* "*" _* EXP1:EXP _* EXP2:EXP+ _* ")" _* {
        return ast("Multiply").add(EXP1,EXP2);
    }
    / DIVIDE   : _* "(" _* "/" _* EXP1:EXP _* EXP2:EXP _* ")" _* {
        return ast("Devide").add(EXP1,EXP2);
    }
    / MODULUS  : _* "(" _* "mod" _* EXP1:EXP _* EXP2:EXP _* ")" _* {
        return ast("Mod").add(EXP1,EXP2);
    }
    / GREATER  : _* "(" _* ">" _* EXP1:EXP _* EXP2:EXP _* ")" _* {
        return ast("Greater").add(EXP1,EXP2);
    }
    / SMALLER  : _* "(" _* "<" _* EXP1:EXP _* EXP2:EXP _* ")" _* { 
        return ast("Smaller").add(EXP1,EXP2); 
    }
    / EQUAL    : _* "(" _* "=" _* EXP1:EXP _* EXP2:EXP _* ")" _* {
        console.log("eq");
        return ast("Equal").add(EXP1,EXP2);
    }

LOGICAL_OP
    = AND_OP   : _* "(" _* "and" _* EXP1:EXP _* EXP2:EXP+ _* ")" _* { 
        return ast("AndOp").add(EXP1,EXP2); 
    }
    / OR_OP    : _* "(" _* "or" _* EXP1:EXP _* EXP2:EXP+  _* ")" _* {
        return ast("OrOp").add(EXP1,EXP2); 
    }
    / NOT_OP   : _* "(" _* "not" _* EXP1:EXP _* ")" _* { 
        return ast("NotOp").add(EXP1);
    }

DEF_STMT
    =  _* "(" _* "define" _* VARIABLE:EXP _* EXP:EXP _* ")" _* {
        //console.log("DEF_STMT");
        return ast("DefStmt").add(VARIABLE,EXP);
    }
    
VARIABLE
    = _* id:id _*{
         //console.log("var",id);
          return ast("Variable").set("id", id);
      }

FUN_EXP
    =  _* "(" _* "fun" _* "(" _* FUN_IDs:VARIABLE* _* ")" _* FUN_BODY:EXP _* ")" _*{
        //console.log("funExp");
        return ast("FunExp").add(FUN_IDs,FUN_BODY);
    }

FUN_CALL
    = _* "(" _* FUN_EXP:EXP _* PARAM:EXP* _* ")" _* {
        //console.log("funCall1");
        return ast("FunCall").add(FUN_EXP,PARAM);
    }
    / _* "(" _* FUN_NAME:id _* PARAM:EXP* _* ")" _*{
        //console.log("funCall2");
        return ast("FunCall").add(FUN_NAME,PARAM);
    }

LAST_EXP
    = _* EXP:EXP _* {
        //console.log("lastExp");
        return ast("LastExp").add(EXP);
    }

IF_EXP
    = _* "(" _* "if" _* TEST_EXP:EXP _* THEN_EXP:EXP _* ELSE_EXP:EXP _* ")" _* {
        //console.log("if_exp");
        return ast("IfExp").add(TEST_EXP, THEN_EXP, ELSE_EXP);
        //console.log("if_exp");
    }

number
    = _* num:('-'?[0-9]+[0-9]*) _*{
        //console.log("num",parseInt(text(), 10))
        return ast("Number").set("num", parseInt(text(), 10));
    }

bool_val
    = "#t" {
        return ast("BoolVal").set("bool", true);
    }
    / "#f" {
        return ast("BoolVal").set("bool", false);
    }

id
   //= id:[a-z]([a-z]/[0-9]/"-")* {
    = !ReservedWord id:$([a-z][a-z0-9\-]*) {
        //console.log("id",id);
        return id;
    }

ReservedWord
  = ( "define" / "if" / "fun" / "print-num" / "print-bool" ) ;

_ "whitespaces"
    = [ \t\r\n] {
      //console.log("white");
    }