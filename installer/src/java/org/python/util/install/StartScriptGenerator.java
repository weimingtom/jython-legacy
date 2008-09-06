package org.python.util.install;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.MessageFormat;
import java.util.Date;

public class StartScriptGenerator {

    protected final static int UNIX_FLAVOUR = 10;
    protected final static int WINDOWS_FLAVOUR = 30;
    protected final static int BOTH_FLAVOUR = 50;
    protected final static String WIN_CR_LF;

    private final static String EXECUTABLE_MODE = "755";

    private final static String JYTHON = "jython";
    private final static String JYTHON_BAT = "jython.bat";
    private final static String JYTHON_JAR = JarInstaller.JYTHON_JAR;

    static {
        int dInt = Integer.parseInt("0d", 16);
        int aInt = Integer.parseInt("0a", 16);
        WIN_CR_LF = new String(new char[] { (char) dInt, (char) aInt });
    }

    private File _targetDirectory;
    private File _javaHome;
    private int _flavour;

    public StartScriptGenerator(File targetDirectory, File javaHome) {
        _targetDirectory = targetDirectory;
        _javaHome = javaHome;
        if (Installation.isWindows()) {
            setFlavour(WINDOWS_FLAVOUR);
        } else {
            // everything else defaults to unix at the moment
            setFlavour(UNIX_FLAVOUR);
        }
    }

    protected void setFlavour(int flavour) {
        _flavour = flavour;
        if (flavour == WINDOWS_FLAVOUR) {
            // check if we should create unix like scripts, too
            if (hasUnixlikeShell()) {
                _flavour = BOTH_FLAVOUR;
           }
        }
    }

    protected int getFlavour() {
        return _flavour;
    }

    protected boolean hasUnixlikeShell() {
        int errorCode = 0;
        try {
            String command = "sh -c env";
            long timeout = 3000;
            ChildProcess childProcess = new ChildProcess(command, timeout);
            childProcess.setDebug(false);
            childProcess.setSilent(true);
            errorCode = childProcess.run();
        } catch (Throwable t) {
            errorCode = 1;
        }
        return errorCode == 0;
    }

    protected final void generateStartScripts() throws IOException {
        generateJythonScript();
    }

    private final void generateJythonScript() throws IOException {
        switch (getFlavour()) {
        case BOTH_FLAVOUR:
            writeToFile(JYTHON_BAT, getJythonScript(WINDOWS_FLAVOUR));
            makeExecutable(writeToFile(JYTHON, getJythonScript(BOTH_FLAVOUR)));
            break;
        case WINDOWS_FLAVOUR:
            writeToFile(JYTHON_BAT, getJythonScript(WINDOWS_FLAVOUR));
            break;
        default:
            makeExecutable(writeToFile(JYTHON, getJythonScript(UNIX_FLAVOUR)));
        }
    }

    /**
     * only <code>protected</code> for unit test use
     */
    protected final String getJythonScript(int flavour) throws IOException {
        if (flavour == WINDOWS_FLAVOUR) {
            return getStartScript(getWindowsJythonTemplate()) + readFromFile(JYTHON_BAT);
        } else {
            return getStartScript(getUnixJythonTemplate()) + readFromFile(JYTHON);
        }
    }

    /**
     * These placeholders are valid for all private methods:
     * 
     * {0} : current date <br>
     * {1} : user.name <br>
     * {2} : java home directory <br>
     * {3} : target directory <br>
     */
    private String getStartScript(String template) throws IOException {
        String parameters[] = new String[4];
        parameters[0] = new Date().toString();
        parameters[1] = System.getProperty("user.name");
        parameters[2] = _javaHome.getCanonicalPath();
        parameters[3] = _targetDirectory.getCanonicalPath();
        return MessageFormat.format(template, (Object[])parameters);
    }

    /**
     * placeholders:
     * 
     * @see getStartScript
     */
    private String getWindowsJythonTemplate() {
        StringBuffer buffer = getWindowsHeaderTemplate();
        buffer.append("set JAVA_HOME=\"{2}\"" + WIN_CR_LF);
        buffer.append("set JYTHON_HOME=\"{3}\"" + WIN_CR_LF);
        buffer.append(WIN_CR_LF);
        return buffer.toString();
    }

    /**
     * placeholders:
     * 
     * @see getStartScript
     */
    private StringBuffer getWindowsHeaderTemplate() {
        StringBuffer buffer = new StringBuffer(1000);
        buffer.append("@echo off" + WIN_CR_LF);
        buffer.append("rem This file was generated by the Jython installer" + WIN_CR_LF);
        buffer.append("rem Created on {0} by {1}" + WIN_CR_LF);
        buffer.append(WIN_CR_LF);
        return buffer;
    }

    /**
     * placeholders:
     * 
     * @see getStartScript
     */
    private String getUnixJythonTemplate() {
        StringBuffer buffer = getUnixHeaderTemplate();
        buffer.append("JAVA_HOME=\"{2}\"\n");
        buffer.append("JYTHON_HOME=\"{3}\"\n");
	buffer.append("\n");
        return buffer.toString();
    }

    /**
     * placeholders:
     * 
     * @see getStartScript
     */
    private StringBuffer getUnixHeaderTemplate() {
        StringBuffer buffer = new StringBuffer(1000);
        buffer.append("#!/usr/bin/env bash\n");
        buffer.append("\n");
        buffer.append("# This file was generated by the Jython installer\n");
        buffer.append("# Created on {0} by {1}\n");
        buffer.append("\n");
        return buffer;
    }

    /**
     * @param fileName The short file name, e.g. JYTHON_BAT
     * 
     * @throws IOException
     */
    private String readFromFile(String fileName) throws IOException {
	File file = new File(new File(_targetDirectory, "bin"), fileName);
	FileReader fileReader = new FileReader(file);
	StringBuffer sb = new StringBuffer();
	char[] b = new char[8192];
	int n;

	while ( (n = fileReader.read(b)) > 0) {
	    sb.append(b, 0, n);
	}
	return sb.toString();
    }

    /**
     * @param fileName The short file name, e.g. JYTHON_BAT
     * @param contents
     * 
     * @throws IOException
     */
    private File writeToFile(String fileName, String contents) throws IOException {
        File file = new File(_targetDirectory, fileName);
        if (file.exists()) {
            file.delete();
        }
        file.createNewFile();
        if (file.exists()) {
            if (file.canWrite()) {
                FileWriter fileWriter = new FileWriter(file);
                fileWriter.write(contents);
                fileWriter.flush();
                fileWriter.close();
            }
        }
        return file;
    }

    /**
     * do a chmod on the passed file
     * 
     * @param scriptFile
     */
    private void makeExecutable(File scriptFile) {
        try {
            String command[] = new String[3];
            command[0] = "chmod";
            command[1] = EXECUTABLE_MODE;
            command[2] = scriptFile.getAbsolutePath();
            long timeout = 3000;
            ChildProcess childProcess = new ChildProcess(command, timeout);
            childProcess.run();
        } catch (Throwable t) {
            t.printStackTrace();
        }
    }

}
