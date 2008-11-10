// Autogenerated AST node
package org.python.antlr.ast;
import org.python.antlr.PythonTree;
import org.antlr.runtime.CommonToken;
import org.antlr.runtime.Token;
import java.io.DataOutputStream;
import java.io.IOException;

public class Dict extends exprType {
    public exprType[] keys;
    public exprType[] values;

    private final static String[] fields = new String[] {"keys", "values"};
    public String[] get_fields() { return fields; }

    public Dict(exprType[] keys, exprType[] values) {
        this.keys = keys;
        if (keys != null) {
            for(int ikeys=0;ikeys<keys.length;ikeys++) {
                addChild(keys[ikeys]);
            }
        }
        this.values = values;
        if (values != null) {
            for(int ivalues=0;ivalues<values.length;ivalues++) {
                addChild(values[ivalues]);
            }
        }
    }

    public Dict(Token token, exprType[] keys, exprType[] values) {
        super(token);
        this.keys = keys;
        if (keys != null) {
            for(int ikeys=0;ikeys<keys.length;ikeys++) {
                addChild(keys[ikeys]);
            }
        }
        this.values = values;
        if (values != null) {
            for(int ivalues=0;ivalues<values.length;ivalues++) {
                addChild(values[ivalues]);
            }
        }
    }

    public Dict(int ttype, Token token, exprType[] keys, exprType[] values) {
        super(ttype, token);
        this.keys = keys;
        if (keys != null) {
            for(int ikeys=0;ikeys<keys.length;ikeys++) {
                addChild(keys[ikeys]);
            }
        }
        this.values = values;
        if (values != null) {
            for(int ivalues=0;ivalues<values.length;ivalues++) {
                addChild(values[ivalues]);
            }
        }
    }

    public Dict(PythonTree tree, exprType[] keys, exprType[] values) {
        super(tree);
        this.keys = keys;
        if (keys != null) {
            for(int ikeys=0;ikeys<keys.length;ikeys++) {
                addChild(keys[ikeys]);
            }
        }
        this.values = values;
        if (values != null) {
            for(int ivalues=0;ivalues<values.length;ivalues++) {
                addChild(values[ivalues]);
            }
        }
    }

    public String toString() {
        return "Dict";
    }

    public String toStringTree() {
        StringBuffer sb = new StringBuffer("Dict(");
        sb.append("keys=");
        sb.append(dumpThis(keys));
        sb.append(",");
        sb.append("values=");
        sb.append(dumpThis(values));
        sb.append(",");
        sb.append(")");
        return sb.toString();
    }

    public <R> R accept(VisitorIF<R> visitor) throws Exception {
        return visitor.visitDict(this);
    }

    public void traverse(VisitorIF visitor) throws Exception {
        if (keys != null) {
            for (int i = 0; i < keys.length; i++) {
                if (keys[i] != null)
                    keys[i].accept(visitor);
            }
        }
        if (values != null) {
            for (int i = 0; i < values.length; i++) {
                if (values[i] != null)
                    values[i].accept(visitor);
            }
        }
    }

    private int lineno = -1;
    public int getLineno() {
        if (lineno != -1) {
            return lineno;
        }
        return getLine();
    }

    public void setLineno(int num) {
        lineno = num;
    }

    private int col_offset = -1;
    public int getCol_offset() {
        if (col_offset != -1) {
            return col_offset;
        }
        return getCharPositionInLine();
    }

    public void setCol_offset(int num) {
        col_offset = num;
    }

}
