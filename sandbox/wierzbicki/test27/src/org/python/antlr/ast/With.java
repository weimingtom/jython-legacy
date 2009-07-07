// Autogenerated AST node
package org.python.antlr.ast;
import org.antlr.runtime.CommonToken;
import org.antlr.runtime.Token;
import org.python.antlr.AST;
import org.python.antlr.PythonTree;
import org.python.antlr.adapter.AstAdapters;
import org.python.antlr.base.excepthandler;
import org.python.antlr.base.expr;
import org.python.antlr.base.mod;
import org.python.antlr.base.slice;
import org.python.antlr.base.stmt;
import org.python.core.ArgParser;
import org.python.core.AstList;
import org.python.core.Py;
import org.python.core.PyObject;
import org.python.core.PyString;
import org.python.core.PyType;
import org.python.expose.ExposedGet;
import org.python.expose.ExposedMethod;
import org.python.expose.ExposedNew;
import org.python.expose.ExposedSet;
import org.python.expose.ExposedType;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.ArrayList;

@ExposedType(name = "_ast.With", base = AST.class)
public class With extends stmt {
public static final PyType TYPE = PyType.fromClass(With.class);
    private expr context_expr;
    public expr getInternalContext_expr() {
        return context_expr;
    }
    @ExposedGet(name = "context_expr")
    public PyObject getContext_expr() {
        return context_expr;
    }
    @ExposedSet(name = "context_expr")
    public void setContext_expr(PyObject context_expr) {
        this.context_expr = AstAdapters.py2expr(context_expr);
    }

    private expr optional_vars;
    public expr getInternalOptional_vars() {
        return optional_vars;
    }
    @ExposedGet(name = "optional_vars")
    public PyObject getOptional_vars() {
        return optional_vars;
    }
    @ExposedSet(name = "optional_vars")
    public void setOptional_vars(PyObject optional_vars) {
        this.optional_vars = AstAdapters.py2expr(optional_vars);
    }

    private java.util.List<stmt> body;
    public java.util.List<stmt> getInternalBody() {
        return body;
    }
    @ExposedGet(name = "body")
    public PyObject getBody() {
        return new AstList(body, AstAdapters.stmtAdapter);
    }
    @ExposedSet(name = "body")
    public void setBody(PyObject body) {
        this.body = AstAdapters.py2stmtList(body);
    }


    private final static PyString[] fields =
    new PyString[] {new PyString("context_expr"), new PyString("optional_vars"), new
                     PyString("body")};
    @ExposedGet(name = "_fields")
    public PyString[] get_fields() { return fields; }

    private final static PyString[] attributes =
    new PyString[] {new PyString("lineno"), new PyString("col_offset")};
    @ExposedGet(name = "_attributes")
    public PyString[] get_attributes() { return attributes; }

    public With(PyType subType) {
        super(subType);
    }
    public With() {
        this(TYPE);
    }
    @ExposedNew
    @ExposedMethod
    public void With___init__(PyObject[] args, String[] keywords) {
        ArgParser ap = new ArgParser("With", args, keywords, new String[]
            {"context_expr", "optional_vars", "body", "lineno", "col_offset"}, 3);
        setContext_expr(ap.getPyObject(0));
        setOptional_vars(ap.getPyObject(1));
        setBody(ap.getPyObject(2));
        int lin = ap.getInt(3, -1);
        if (lin != -1) {
            setLineno(lin);
        }

        int col = ap.getInt(4, -1);
        if (col != -1) {
            setLineno(col);
        }

    }

    public With(PyObject context_expr, PyObject optional_vars, PyObject body) {
        setContext_expr(context_expr);
        setOptional_vars(optional_vars);
        setBody(body);
    }

    public With(Token token, expr context_expr, expr optional_vars, java.util.List<stmt> body) {
        super(token);
        this.context_expr = context_expr;
        addChild(context_expr);
        this.optional_vars = optional_vars;
        addChild(optional_vars);
        this.body = body;
        if (body == null) {
            this.body = new ArrayList<stmt>();
        }
        for(PythonTree t : this.body) {
            addChild(t);
        }
    }

    public With(Integer ttype, Token token, expr context_expr, expr optional_vars,
    java.util.List<stmt> body) {
        super(ttype, token);
        this.context_expr = context_expr;
        addChild(context_expr);
        this.optional_vars = optional_vars;
        addChild(optional_vars);
        this.body = body;
        if (body == null) {
            this.body = new ArrayList<stmt>();
        }
        for(PythonTree t : this.body) {
            addChild(t);
        }
    }

    public With(PythonTree tree, expr context_expr, expr optional_vars, java.util.List<stmt> body) {
        super(tree);
        this.context_expr = context_expr;
        addChild(context_expr);
        this.optional_vars = optional_vars;
        addChild(optional_vars);
        this.body = body;
        if (body == null) {
            this.body = new ArrayList<stmt>();
        }
        for(PythonTree t : this.body) {
            addChild(t);
        }
    }

    @ExposedGet(name = "repr")
    public String toString() {
        return "With";
    }

    public String toStringTree() {
        StringBuffer sb = new StringBuffer("With(");
        sb.append("context_expr=");
        sb.append(dumpThis(context_expr));
        sb.append(",");
        sb.append("optional_vars=");
        sb.append(dumpThis(optional_vars));
        sb.append(",");
        sb.append("body=");
        sb.append(dumpThis(body));
        sb.append(",");
        sb.append(")");
        return sb.toString();
    }

    public <R> R accept(VisitorIF<R> visitor) throws Exception {
        return visitor.visitWith(this);
    }

    public void traverse(VisitorIF<?> visitor) throws Exception {
        if (context_expr != null)
            context_expr.accept(visitor);
        if (optional_vars != null)
            optional_vars.accept(visitor);
        if (body != null) {
            for (PythonTree t : body) {
                if (t != null)
                    t.accept(visitor);
            }
        }
    }

    private int lineno = -1;
    @ExposedGet(name = "lineno")
    public int getLineno() {
        if (lineno != -1) {
            return lineno;
        }
        return getLine();
    }

    @ExposedSet(name = "lineno")
    public void setLineno(int num) {
        lineno = num;
    }

    private int col_offset = -1;
    @ExposedGet(name = "col_offset")
    public int getCol_offset() {
        if (col_offset != -1) {
            return col_offset;
        }
        return getCharPositionInLine();
    }

    @ExposedSet(name = "col_offset")
    public void setCol_offset(int num) {
        col_offset = num;
    }

}
