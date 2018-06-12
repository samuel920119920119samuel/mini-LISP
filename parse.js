var fs      = require("fs");
var ASTY    = require("asty");
var PEG     = require("pegjs");
var PEGUtil = require("pegjs-util");

var asty = new ASTY();
var parser = PEG.generate(fs.readFileSync("rule.pegjs", "utf8"));
var result = PEGUtil.parse(parser, fs.readFileSync(process.argv[2], "utf8"), {
    startRule: "PROGRAM",
    makeAST: function (line, column, offset, args) {
        return asty.create.apply(asty, args).pos(line, column, offset);
    }
})

var dic={};

if (result.error !== null)
    console.log("ERROR: Parsing Failure:\n" +
        PEGUtil.errorMessage(result.error, true).replace(/^/mg, "ERROR: "));
else{
    console.log(result.ast.dump().replace(/\n$/, ""));
    interpret(result.ast, dic);
}

function getVal(val, dic){
    switch(typeof(val)){
        case "number":
            return val;
        case "boolean":
            if(val)        return true;
            else if(!val)  return false;
        case "string":
            if(dic[val]!=undefined)    return dic[val];
            else                       console.log("undefine: ", val);
        default:
            console.log("error when getting value: ", val);
    }
}

function interpret(node, dic){
    switch(node.T){
        case "Number":
            return node.A["num"];
        case "Variable":
            return node.A["id"];
        case "BoolVal":
            return node.A["bool"];
        case "Program":
            node.C.forEach(child => interpret(child,dic));
            break;
        case "PrintNum":
            let num = getVal(interpret(node.C[0],dic),dic);
            console.log("ans: ", num);
            break;
        case "PrintBool":
            let bool = getVal(interpret(node.C[0],dic),dic);
            if(bool)    console.log("ans: ", "#t");
            else        console.log("ans: ", "#f");
            break;
        case "DefStmt":
            let variable = interpret(node.C[0],dic);
            let id       = interpret(node.C[1],dic);
            try{
                dic[variable] = id;
            }catch(e){
                console.log(id, "re-defined, ", "err: ", e);
            }
            break;
        case "FunCall":
            // funInfo = [funIds, funBodyTree], from FunExp
            let funInfo = interpret(node.C[0],dic);
            if(node.C[0].T == "Variable")   funInfo = dic[funInfo];
            let params = [];
            (node.C.slice(1)).forEach( child => params.push(interpret(child,dic)) );

            var funDic={};
            for (let i = 0; i < params.length; i++)
                funDic[funInfo[0][i]]=params[i];

            return getVal(interpret(funInfo[1], funDic),funDic);
        case "FunExp":
            let funIds  = [],
                funBodyTree = node.C[node.C.length-1];
            (node.C.slice(0,node.C.length-1)).forEach( child=>funIds.push(interpret(child,dic)) );
            return [funIds, funBodyTree];
            //    return (function(funIds, funDic){
            //    var funDoc = {};
            //    funIds.forEach( id => funDic[id]=funIds);
            //    interpret(funBody, funDic);
            //});
        case "IfExp":
             if(interpret(node.C[0],dic))   return interpret(node.C[1],dic);
             else                           return interpret(node.C[2],dic);
        case "Plus":
            let plusAns=0;
            node.C.forEach(child => plusAns+=getVal(interpret(child,dic),dic));
            return plusAns;
        case "Minus":
            let minuend    = getVal(interpret(node.C[0],dic),dic),
                subtrahend = getVal(interpret(node.C[1],dic),dic);
            return minuend - subtrahend;
        case "Multiply":
            let mulAns=1;
            node.C.forEach(child => mulAns*=getVal(interpret(child,dic),dic));
            return mulAns;
        case "Devide":
            let dividend = getVal(interpret(node.C[0],dic),dic),
                divisor  = getVal(interpret(node.C[1],dic),dic);
            return parseInt(dividend / divisor);
        case "Mod":
            let mod1 = getVal(interpret(node.C[0],dic),dic),
                mod2 = getVal(interpret(node.C[1],dic),dic);
            return mod1 % mod2;
        case "Greater":
            let greater1 = getVal(interpret(node.C[0],dic),dic),
                greater2 = getVal(interpret(node.C[1],dic),dic);
            return greater1 > greater2;
        case "Smaller":
            let smaller1 = getVal(interpret(node.C[0],dic),dic),
                smaller2 = getVal(interpret(node.C[1],dic),dic);
            return smaller1 < smaller2;
        case "Equal":
            let equal1 = getVal(interpret(node.C[0],dic),dic),
                equal2 = getVal(interpret(node.C[1],dic),dic);
            return equal1 == equal2;
        case "AndOp":
            let andAns = true;
            node.C.forEach(child => andAns=andAns&&getVal(interpret(child,dic),dic));
            return andAns;
        case "OrOp":
            let orAns = false;
            node.C.forEach(child => orAns=orAns||getVal(interpret(child,dic),dic));
            return orAns;
        case "NotOp":
            return !interpret(node.C[0],dic);
        default:
            console.log("interpret error");
    }   
}