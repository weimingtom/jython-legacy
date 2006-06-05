package org.python.util.install;

import java.io.File;
import java.io.IOException;
import java.util.Date;

import junit.framework.TestCase;

public class StartScriptGeneratorTest extends TestCase {

    private StartScriptGenerator _generator;
    
    protected void setUp() throws Exception {
        _generator = new StartScriptGenerator(new File("C:\\target"), new File("C:\\java")); // dummy values here
    }
    
    public void testUnix() throws IOException {
        _generator.setFlavour(StartScriptGenerator.UNIX_FLAVOUR);
        StringBuffer buf = new StringBuffer(100);
        buf.append("#!/bin/sh\n");
        buf.append("\n");
        buf.append("# This file was generated by the Jython installer\n");
        buf.append("# Created on " + (new Date().toString()) + " by " + System.getProperty("user.name") + "\n");
        buf.append("\n");
        buf.append("CP=C:\\target/" + JarInstaller.JYTHON_JAR + "\n");
        buf.append("if [ ! -z \"$CLASSPATH\" ]\n");  // quotes around $CLASSPATH are essential for Solaris
        buf.append("then\n");
        buf.append("  CP=$CP:$CLASSPATH\n");
        buf.append("fi\n");
        buf.append("\"C:\\java/bin/java\" -Dpython.home=\"C:\\target\" -classpath \"$CP\" org.python.util.jython \"$@\"\n");
        assertEquals(buf.toString(), _generator.getJythonScript());
        
        buf = new StringBuffer(50);
        buf.append("#!/bin/sh\n");
        buf.append("\n");
        buf.append("# This file was generated by the Jython installer\n");
        buf.append("# Created on " + (new Date().toString()) + " by " + System.getProperty("user.name") + "\n");
        buf.append("\n");
        buf.append("\"C:\\target/jython\" \"C:\\target/Tools/jythonc/jythonc.py\" \"$@\"\n");
        assertEquals(buf.toString(), _generator.getJythoncScript());
    }
    
    public void testWindows() throws IOException {
        StringBuffer winBuf = new StringBuffer(100);
        winBuf.append("@echo off\n");
        winBuf.append("rem This file was generated by the Jython installer\n");
        winBuf.append("rem Created on " + (new Date().toString()) + " by " + System.getProperty("user.name") + "\n");
        winBuf.append("\n");
        winBuf.append("set ARGS=\n");
        winBuf.append("\n");
        winBuf.append(":loop\n");
        winBuf.append("if [%1] == [] goto end\n");
        winBuf.append("    set ARGS=%ARGS% %1\n");
        winBuf.append("    shift\n");
        winBuf.append("    goto loop\n");
        winBuf.append(":end\n");
        winBuf.append("\n");
        
        _generator.setFlavour(StartScriptGenerator.WINDOWS_FLAVOUR);
        StringBuffer buf = new StringBuffer(100);
        buf.append(winBuf);
        buf.append("\"C:\\java\\bin\\java.exe\" -Dpython.home=\"C:\\target\" -classpath \"C:\\target\\" + JarInstaller.JYTHON_JAR + ";%CLASSPATH%\" org.python.util.jython %ARGS%\n");
        assertEquals(buf.toString(), _generator.getJythonScript());
        
        buf = new StringBuffer(100);
        buf.append(winBuf);
        buf.append("\"C:\\target\\jython.bat\" \"C:\\target\\Tools\\jythonc\\jythonc.py\" %ARGS%\n");
        assertEquals(buf.toString(), _generator.getJythoncScript());
    }
    
}
