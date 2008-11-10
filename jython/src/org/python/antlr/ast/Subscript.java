// Autogenerated AST node
package org.python.antlr.ast;
import org.python.antlr.PythonTree;
import org.antlr.runtime.CommonToken;
import org.antlr.runtime.Token;
import java.io.DataOutputStream;
import java.io.IOException;

public class Subscript extends exprType implements Context {
    public exprType value;
    public sliceType slice;
    public expr_contextType ctx;

    private final static String[] fields = new String[] {"value", "slice",
                                                          "ctx"};
    public String[] get_fields() { return fields; }

    public Subscript(exprType value, sliceType slice, expr_contextType ctx) {
        this.value = value;
        addChild(value);
        this.slice = slice;
        this.ctx = ctx;
    }

    public Subscript(Token token, exprType value, sliceType slice,
    expr_contextType ctx) {
        super(token);
        this.value = value;
        addChild(value);
        this.slice = slice;
        this.ctx = ctx;
    }

    public Subscript(int ttype, Token token, exprType value, sliceType slice,
    expr_contextType ctx) {
        super(ttype, token);
        this.value = value;
        addChild(value);
        this.slice = slice;
        this.ctx = ctx;
    }

    public Subscript(PythonTree tree, exprType value, sliceType slice,
    expr_contextType ctx) {
        super(tree);
        this.value = value;
        addChild(value);
        this.slice = slice;
        this.ctx = ctx;
    }

    public String toString() {
        return "Subscript";
    }

    public String toStringTree() {
        StringBuffer sb = new StringBuffer("Subscript(");
        sb.append("value=");
        sb.append(dumpThis(value));
        sb.append(",");
        sb.append("slice=");
        sb.append(dumpThis(slice));
        sb.append(",");
        sb.append("ctx=");
        sb.append(dumpThis(ctx));
        sb.append(",");
        sb.append(")");
        return sb.toString();
    }

    public <R> R accept(VisitorIF<R> visitor) throws Exception {
        return visitor.visitSubscript(this);
    }

    public void traverse(VisitorIF visitor) throws Exception {
        if (value != null)
            value.accept(visitor);
        if (slice != null)
            slice.accept(visitor);
    }

    public void setContext(expr_contextType c) {
        this.ctx = c;
    }

    public int getLineno() {
        return getLine();
    }

    public int getCol_offset() {
        return getCharPositionInLine();
    }

}
