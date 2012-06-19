package tc.catseye.whothm;

import java.util.Map;
import java.util.HashMap;

class ParseException extends Exception {
    private int line;
    private String message;
    
    public ParseException(int line, String message) {
        this.line = line;
        this.message = message;
    }
    
    public String asString() {
        return "Line " + this.line + ": " + this.message;
    }
}

class Parser {
    private String source;
    private int pos;
    private int line;
    private String token;
    private Map<String, Rectangle> rectMap = new HashMap<String, Rectangle>();
    private Map<String, TruthTable> ttMap = new HashMap<String, TruthTable>();
    private Machine m;

    Parser(String source) {
        this.source = source;
        this.line = 1;
        this.pos = 0;
        try {
            scan();
        } catch (ParseException pe) {
        }
    }

    public String scan() throws ParseException {
        int len = 0;
        while (pos < source.length() && Character.isWhitespace(source.charAt(pos))) {
            if (source.charAt(pos) == '\n') {
                line++;
            }
            pos++;
        }
        if (pos >= source.length()) {
            // At end of source
        } else if (Character.isLetter(source.charAt(pos))) {
            while (((pos + len) < source.length()) && Character.isLetter(source.charAt(pos + len))) {
                len++;
            }
        } else if (source.charAt(pos) == '-' || Character.isDigit(source.charAt(pos))) {
            if (source.charAt(pos) == '-') {
                len++;
            }
            while (Character.isDigit(source.charAt(pos + len))) {
                len++;
            }
        } else if (source.charAt(pos) == '+' && source.charAt(pos + 1) == '=') {
            len = 2;
        } else if (source.charAt(pos) == ':' && source.charAt(pos + 1) == '=') {
            len = 2;
        } else {
            len = 1;
        }

        token = source.substring(pos, pos + len);
        //System.out.println("Scanned " + token + ", length " + token.length());
        if (token.length() != len) {
            throw new ParseException(line, "Premature end of program");
        }
        pos += len;
        return token;
    }

    public boolean tokenIsIntLit() {
        return (token.charAt(0) == '-' || Character.isDigit(token.charAt(0)));
    }

    public int scanIntLit() throws ParseException {
        int val = Integer.parseInt(token);
        scan();
        return val;
    }

    public String getToken() {
        return token;
    }

    public boolean tokenIs(String s) {
        return token.equals(s);
    }

    public void expect(String s) throws ParseException {
        if (!token.equals(s)) {
            throw new ParseException(line, "Expected '" + s + "', but found '" + token + "'");
        } else {
            scan();
        }
    }

    public Machine parse() throws ParseException {
        m = new Machine();
        while (!tokenIs("begin")) {
            parseDecl();
            expect(";");
        }
        expect("begin");
        while (!tokenIs("end")) {
            parseCommand();
            expect(";");
        }
        expect("end");
        return m;
    }

    public void parseDecl() throws ParseException {
        String name = token;
        scan();
        expect(":=");
        if (tokenIs("(")) {
            // it's a rectangle
            expect("(");
            Integer x = scanIntLit();
            expect(",");
            Integer y = scanIntLit();
            expect(",");
            Integer w = scanIntLit();
            expect(",");
            Integer h = scanIntLit();
            expect(")");
            rectMap.put(name, new Rectangle(x, y, w, h));
        } else {
            // it's a truthtable
            TruthTable tt = new TruthTable();
            String truthPair = token;
            tt.mapToTrue(truthPair);
            scan();
            while (tokenIs("/")) {
                expect("/");
                truthPair = token;
                tt.mapToTrue(truthPair);
                scan();
            }
            ttMap.put(name, tt);
        }
    }

    private Rectangle readRect() throws ParseException {
        String rectName = token;
        Rectangle rect = rectMap.get(rectName);
        if (rect == null) {
            throw new ParseException(line, "Undefined rectangle '" + rectName + "'");
        }
        scan();
        return rect;
    }

    public void parseCommand() throws ParseException {
        if (tokenIs("draw")) {
            expect("draw");
            Rectangle rect = readRect();
            expect(",");
            String ttName = token;
            TruthTable tt = ttMap.get(ttName);
            if (tt == null) {
                throw new ParseException(line, "Undefined truth table '" + ttName + "'");
            }
            scan();
            m.addDrawCommand(rect, tt);
        } else {
            Rectangle rect = readRect();
            expect(".");
            String member = token;
            scan();
            expect("+=");
            if (tokenIsIntLit()) {
                Integer value = scanIntLit();
                m.addDeltaCommand(rect, member, value);
            } else {
                Rectangle srcRect = readRect();
                expect(".");
                String srcMember = token;
                scan();
                m.addDeltaIndirectCommand(rect, member, srcRect, srcMember);
            }
        }
    }
}
