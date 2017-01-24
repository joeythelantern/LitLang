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

Digit = [0-9]+
Letter = [a-zA-Z]

Punc = \! | \? | \; | \,
Streetname = \_[A-Za-z0-9]+
Identifier = [A-Za-z]([A-Za-z]|[0-9_])+

EOL = \n|\r\n|\u2028|\u2029|\u000B|\u000C|\u0085

%eofval{
    return symbol("EOF",sym.EOF);
%eofval}

%caseless
%states YYINITIAL

%%

<YYINITIAL> {

  {Streetname}{ return symbol("STREETNAME", STREETNAME); }
  {Punc}			{ return symbol("PUNC", PUNC); }

  "%"         {return symbol("SUHDUDE", "SUHDUDE"); }
  "(:"        { return symbol("LPAREN", LPAREN); }
  ":)"        { return symbol("RPAREN", RPAREN); }
  "$"		   		{ return symbol("DOLLA", DOLLA); }
  ":"		   		{ return symbol("COLON", COLON); }
  "#"		   		{ return symbol("HASHTAG", HASHTAG); }
  "\""		   	{ return symbol("QM", QM); }
  "\*"				{ return symbol("STAR", STAR); }
  "\@"				{ return symbol("AT", AT); }
	
  "MIXTAPE"    	    	{ return symbol("MIXTAPE", MIXTAPE); }
  "AKA" 	    	    	{ return symbol("AKA", AKA); }
  "PLAYA"         		{ return symbol("PLAYA", PLAYA); }
  "FIRE"          		{ return symbol("FIRE", FIRE); }
  "BONES"          		{ return symbol("BONES", BONES); }
  "WORDONTHASTREET"   { return symbol("WORDONTHASTREET", WORDONTHASTREET); }
  "DAB"            		{ return symbol("DAB", DAB); }
  "PARTY"   	   	    { return symbol("PARTY", PARTY); }
  "LIT"        		    { return symbol("LIT", LIT); }
  "NOTLIT"        	  { return symbol("NOTLIT", NOTLIT); }
  "GETMONEY"         	{ return symbol("GETMONEY", GETMONEY); }
  "THROWMONEY"        { return symbol("THROWMONEY", THROWMONEY); }
  "BALLOUT"          	{ return symbol("BALLOUT", BALLOUT); }
  "CUT"           		{ return symbol("CUT", CUT); }
  "CHECK"	         		{ return symbol("CHECK", CHECK); }
  "REK"	   	       		{ return symbol("REK", REK); }
  "YOSEWF"	      		{ return symbol("YOSEWF", YOSEWF); }
  "BOUNCE"	       		{ return symbol("BOUNCE", BOUNCE); }
  "PREACH"	       		{ return symbol("PREACH", PREACH); }
  "WEAK"	        		{ return symbol("WEAK", WEAK); }
  "WINNING"	      		{ return symbol("WINNING", WINNING); }
  "ONMYLEVEL"	       	{ return symbol("ONMYLEVEL", ONMYLEVEL); }
  "OTHERLEVEL"	    	{ return symbol("OTHERLEVEL", OTHERLEVEL); }
  "TURNUP"	       		{ return symbol("TURNUP", TURNUP); }
  "DEAD"	        		{ return symbol("DEAD", DEAD); }
  "SON"	   	      		{ return symbol("SON", SON); }
  
  {Digit}			{ return symbol("DIGIT", DIGIT); }
  
  {Identifier}		{ return symbol("IDENTIFIER", IDENTIFIER); }
  
    
  {Whitespace} { }

}

{EOL} { /* end of line */ }
[^]  { throw new RuntimeException("Illegal Character \"" + yytext() +
                          "\" at line " + yyline+1 + ", column " + yycolumn+1); }

