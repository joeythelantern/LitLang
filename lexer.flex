package com.madebyjeffrey;
import java_cup.runtime.ComplexSymbolFactory;
import java_cup.runtime.ComplexSymbolFactory.Location;
import java_cup.runtime.Symbol;
import java.lang.*;
import java.io.InputStreamReader;
import java.util.stream.*;

%%

%class Lexer
%implements sym
%public
%unicode
%line
%column
%cup
%char
%{
	private String filename;
	public String getFilename() {
		return filename;
	}

    public void setFilename(String filename) {
        this.filename = filename;
    }


    public Lexer(ComplexSymbolFactory sf, java.io.InputStream is){
		this(new InputStreamReader(is));
        symbolFactory = sf;
    }
	public Lexer(ComplexSymbolFactory sf, java.io.Reader reader){
		this(reader);
        symbolFactory = sf;
    }

    private StringBuffer string = new StringBuffer();
    private ComplexSymbolFactory symbolFactory;
    private int csline,cscolumn;

    public Symbol symbol(String name, int code){
		return symbolFactory.newSymbol(name, code,
						new Location(filename, yyline+1,yycolumn+1, yychar), // -yylength()
						new Location(filename, yyline+1,yycolumn+yylength(), yychar+yylength())
				);
    }
    public Symbol symbol(String name, int code, String lexem){
	return symbolFactory.newSymbol(name, code,
						new Location(filename, yyline+1, yycolumn +1, yychar),
						new Location(filename, yyline+1,yycolumn+yylength
						(), yychar+yylength()), lexem);
    }

     private Symbol symbol(String name, int sym, Object val,int buflength) {
          Location left = new Location(yyline+1,yycolumn+yylength()-buflength,yychar+yylength()-buflength);
          Location right= new Location(yyline+1,yycolumn+yylength(), yychar+yylength());
          return symbolFactory.newSymbol(name, sym, left, right,val);
     }

    protected void emit_warning(String message){
    	System.out.println("scanner warning: " + message + " at : 2 "+
    			(yyline+1) + " " + (yycolumn+1) + " " + yychar);
    }

    protected void emit_error(String message){
    	System.out.println("scanner error: " + message + " at : 2" +
    			(yyline+1) + " " + (yycolumn+1) + " " + yychar);
    }

    // Removes a prefix, and gets rid of underscores
    protected String filterNumber(String text, int prefix) {
    	return text.substring(prefix).codePoints()
    		.filter(cp -> cp != '_')
    		.collect(StringBuilder::new, StringBuilder::appendCodePoint, StringBuilder::append)
    		.toString();
    }

    protected String filterNumber(String text) {
    	return filterNumber(text, 0);
	}
%}


Newline    = \r|\n|\r\n
Whitespace = [ \t\f]|{Newline}

Digits = [0-9]+
HexDigits = [0-9A-Za-z]+
ExponentPart = [eE][+-]{Digits}


Greek	   = [\u0391-\u03a1]|[\u03a3-\u03a9]|[\u03b1-\u03c9]
Letter	   = [A-Za-z] | {Greek}
Identifier = ({Letter}|[0-9_])+

EOL = \n|\r\n|\u2028|\u2029|\u000B|\u000C|\u0085

%eofval{
    return symbol("EOF",sym.EOF);
%eofval}

%caseless
%states YYINITIAL, LINECOMMENT, MCOMMENT1, MCOMMENT2, STRING, NUMBER

%%

<YYINITIAL> {




 /* Integer Literals */
 {Digits}		  { yybegin(NUMBER); return symbol("Decimals", Digits, yytext()); }
 0[xX]{HexDigits} { return symbol("Hexadecimal Literal", HexLit, yytext().substring(2)); }


  "("          { return symbol("(", LPAREN); }
  ")"          { return symbol(")", RPAREN); }
  ","		   { return symbol("COMMA", COMMA);}
  ":"		   { return symbol("COLON", COLON);}
  ";"		   { return symbol("SEMICOLON", SEMICOLON);}
  ":="		   { return symbol("COLON_EQUALS", COLON_EQUALS);}
  "="		   { return symbol("EQUALS", EQUALS); }
  "<>"		   { return symbol("NOT_EQUALS", NOT_EQUALS); }
  "."      	   { return symbol("Decimal Point", DECIMAL); }
  "shr"		   { return symbol("SHR", SHR);}
  "shl"		   { return symbol("SHL", SHL);}
  "and"		   { return symbol("AND", AND);}
  "or"		   { return symbol("OR", OR);}
  "xor"		   { return symbol("XOR", XOR);}
  "*"		   { return symbol("STAR", MULTIPLY);}
  "/"		   { return symbol("SLASH", DIVIDE);}
  "+"		   { return symbol("PLUS", PLUS);}
  "-"		   { return symbol("MINUS", MINUS);}
  "^"		   { return symbol("POWER", POWER);}

  "PROGRAM"    { return symbol("PROGRAM", PROGRAM); }
  "USES"       { return symbol("USES", USES); }
  "INT"        { return symbol("INT", INT_TYPE); }
  "REAL"       { return symbol("REAL", REAL_TYPE); }
  "STRING"     { return symbol("STRING", STRING_TYPE); }
  "BEGIN"      { return symbol("BEGIN", BEGIN); }
  "END"        { return symbol("END", END); }
  "VAR"        { return symbol("VAR", VAR); }
  "RETURN"     { return symbol("RETURN", RETURN); }
  "IF"         { return symbol("IF", IF); }
  "THEN"       { return symbol("THEN", THEN); }
  "ELSE"       { return symbol("ELSE", ELSE); }
  {Identifier} { return symbol("Identifier", IDENTIFIER, yytext()); }


/* comments */
	\{\- { yybegin(MCOMMENT1); }
	\/\*\* { yybegin(MCOMMENT2); }
	\# { yybegin(LINECOMMENT); }

	\" { string.setLength(0); yybegin(STRING);  }

	{Whitespace} { }

}

<MCOMMENT1> {
	\-\} { yybegin(YYINITIAL); }
	. {}
}

<MCOMMENT2> {
	\*\*\/ { yybegin(YYINITIAL); }
	. {}
}

<LINECOMMENT> {
	{EOL}	{ yybegin(YYINITIAL); }
	. {}
}

<STRING> {
  \"	                         { yybegin(YYINITIAL);
                                   return symbol("STRING", STRING_LIT, string.toString(), string.length()+1);
                                   }
  [^\n\r\"\\]+                   { string.append( yytext() ); }
  \\t                            { string.append('\t'); }
  \\n                            { string.append('\n'); }

  \\r                            { string.append('\r'); }
  \\\"                           { string.append('\"'); }
  \\                             { string.append('\\'); }
}

<NUMBER> {
	"."      { return symbol("Decimal Point", DECIMAL); }
	{Digits} { return symbol("Digits", Digits, yytext()); }
	{ExponentPart}  { return symbol("Exponent Part", ExponentPart, yytext()); }

	[^] { yypushback(1); yybegin(YYINITIAL); } // this will process anything else again as the YYINITIAL rule
}

{EOL} { /* end of line */ }
[^]  { throw new RuntimeException("Illegal Character \"" + yytext() +
                          "\" at line " + yyline+1 + ", column " + yycolumn+1); }

