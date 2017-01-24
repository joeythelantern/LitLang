package com.madebyjeffrey;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java_cup.runtime.*;
import java_cup.runtime.ComplexSymbolFactory;

public class Main {

    public static void main(String[] args) {
        ComplexSymbolFactory f = new ComplexSymbolFactory();

        File file = new File("input.txt");
        try (FileInputStream fis = new FileInputStream(file)) {
            Lexer lexer = new Lexer(f,fis);
            lexer.setFilename("input.txt");
            Parser parser = new Parser(lexer, f);
            parser.parse();
            //System.out.printf("Compile program %s\n", program._name);
            //System.out.printf("Number of methods: %d\n", program._methods.size());

            //System.out.println(program.toJava());
        } catch (IOException e1) {
            e1.printStackTrace();
        } catch (Exception e2) {
            e2.printStackTrace();
        }
    }
}
