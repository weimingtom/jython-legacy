package org.python.util.install;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.MessageFormat;
import java.util.Date;

public class StartScriptGenerator {

    private File _targetDirectory;

    public StartScriptGenerator(File targetDirectory) {
        _targetDirectory = targetDirectory;
    }

    protected final void generateJythonForWindows() throws IOException {
        writeToFile("jython.bat", getStartScript(getWindowsJythonTemplate()));
    }

    protected final void generateJythoncForWindows() throws IOException {
        writeToFile("jythonc.bat", getStartScript(getWindowsJythoncTemplate()));
    }

    protected final void generateJythonForUnix() throws IOException {
        writeToFile("jython", getStartScript(getUnixJythonTemplate()));
    }

    protected final void generateJythoncForUnix() throws IOException {
        writeToFile("jythonc", getStartScript(getUnixJythoncTemplate()));
    }

    /**
     * These placeholders are valid for all private methods:
     * 
     * {0} : current date <br>
     * {1} : user.name <br>
     * {2} : java.home <br>
     * {3} : target directory <br>
     */
    private String getStartScript(String template) throws IOException {
        String parameters[] = new String[4];
        parameters[0] = new Date().toString();
        parameters[1] = System.getProperty("user.name");
        parameters[2] = System.getProperty("java.home");
        parameters[3] = _targetDirectory.getCanonicalPath();
        return MessageFormat.format(template, parameters);
    }

    /**
     * placeholders:
     * 
     * @see getStartScript
     */
    private String getWindowsJythonTemplate() {
        StringBuffer buffer = getWindowsHeaderTemplate();
        buffer.append("\"{2}\\bin\\java.exe\" -Dpython.home=\"{3}\" -classpath \"{3}\\jython.jar;%CLASSPATH%\" org.python.util.jython %ARGS%\n");
        return buffer.toString();
    }

    /**
     * placeholders:
     * 
     * @see getStartScript
     */
    private String getWindowsJythoncTemplate() {
        StringBuffer buffer = getWindowsHeaderTemplate();
        buffer.append("\"{3}\\jython.bat\" \"{3}\\Tools\\jythonc\\jythonc.py\" %ARGS%\n");
        return buffer.toString();
    }

    /**
     * placeholders:
     * 
     * @see getStartScript
     */
    private StringBuffer getWindowsHeaderTemplate() {
        StringBuffer buffer = new StringBuffer(1000);
        buffer.append("@echo off\n");
        buffer.append("rem This file was generated by the Jython installer\n");
        buffer.append("rem Created on {0} by {1}\n");
        buffer.append("\n");
        buffer.append("set ARGS=\n");
        buffer.append("\n");
        buffer.append(":loop\n");
        buffer.append("if [%1] == [] goto end\n");
        buffer.append("    set ARGS=%ARGS% %1\n");
        buffer.append("    shift\n");
        buffer.append("    goto loop\n");
        buffer.append(":end\n");
        buffer.append("\n");
        return buffer;
    }

    /**
     * placeholders:
     * 
     * @see getStartScript
     */
    private String getUnixJythonTemplate() {
        StringBuffer buffer = getUnixHeaderTemplate();
        buffer.append("CP={3}/jython.jar\n");
        buffer.append("if [ ! -z $CLASSPATH ]\nthen\n  CP=$CP:$CLASSPATH\nfi\n");
        buffer.append("\"{2}/bin/java\" -Dpython.home=\"{3}\" -classpath \"$CP\" org.python.util.jython \"$@\"\n");
        return buffer.toString();
    }

    /**
     * placeholders:
     * 
     * @see getStartScript
     */
    private String getUnixJythoncTemplate() {
        StringBuffer buffer = getUnixHeaderTemplate();
        buffer.append("\"{3}/jython\" \"{3}/Tools/jythonc/jythonc.py\" \"$@\"\n");
        return buffer.toString();
    }

    /**
     * placeholders:
     * 
     * @see getStartScript
     */
    private StringBuffer getUnixHeaderTemplate() {
        StringBuffer buffer = new StringBuffer(1000);
        buffer.append("#!/bin/sh\n");
        buffer.append("\n");
        buffer.append("# This file was generated by the Jython installer\n");
        buffer.append("# Created on {0} by {1}\n");
        buffer.append("\n");
        return buffer;
    }

    /**
     * @param fileName The short file name, e.g. "jython.bat"
     * @param contents
     * 
     * @throws IOException
     */
    private void writeToFile(String fileName, String contents) throws IOException {
        File file = new File(_targetDirectory, fileName);
        if (file.exists()) {
            file.delete();
        }
        file.createNewFile();
        if (file.canWrite()) {
            FileWriter fileWriter = new FileWriter(file);
            fileWriter.write(contents);
            fileWriter.flush();
            fileWriter.close();
        }
    }

}