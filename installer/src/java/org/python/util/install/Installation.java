package org.python.util.install;

import java.awt.GraphicsEnvironment; // should be allowed on headless systems
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.text.MessageFormat;
import java.util.Locale;
import java.util.Properties;
import java.util.ResourceBundle;

public class Installation {
    protected static final String ALL = "1";
    protected static final String STANDARD = "2";
    protected static final String MINIMUM = "3";
    protected static final String OS_NAME = "os.name";
    protected static final String OS_VERSION = "os.version";
    protected static final String EMPTY = "";

    protected final static int NORMAL_RETURN = 0;
    protected final static int ERROR_RETURN = 1;

    private static final String RESOURCE_CLASS = "org.python.util.install.TextConstants";

    private static ResourceBundle _textConstants = ResourceBundle.getBundle(RESOURCE_CLASS, Locale.getDefault());

    public static void main(String args[]) {
        try {
            JarInfo jarInfo = new JarInfo();
            InstallerCommandLine commandLine = new InstallerCommandLine(jarInfo);
            if (!commandLine.setArgs(args) || commandLine.hasHelpOption()) {
                commandLine.printHelp();
                System.exit(1);
            } else {
                if (!useGUI(commandLine)) {
                    ConsoleInstaller consoleInstaller = new ConsoleInstaller(commandLine, jarInfo);
                    consoleInstaller.install();
                    System.exit(0);
                } else {
                    new FrameInstaller(jarInfo);
                }
            }
        } catch (InstallationCancelledException ice) {
            ConsoleInstaller.message((Installation.getText(TextKeys.INSTALLATION_CANCELLED)));
            System.exit(1);
        } catch (InstallerException ie) {
            ie.printStackTrace();
            System.exit(1);
        } catch (Throwable t) {
            t.printStackTrace();
            System.exit(1);
        }
    }

    protected static String getText(String key) {
        return _textConstants.getString(key);
    }

    protected static String getText(String key, String parameter0) {
        String parameters[] = new String[1];
        parameters[0] = parameter0;
        return MessageFormat.format(_textConstants.getString(key), parameters);
    }

    protected static String getText(String key, String parameter0, String parameter1) {
        String parameters[] = new String[2];
        parameters[0] = parameter0;
        parameters[1] = parameter1;
        return MessageFormat.format(_textConstants.getString(key), parameters);
    }

    protected static void setLanguage(Locale locale) {
        _textConstants = ResourceBundle.getBundle(RESOURCE_CLASS, locale);
    }

    protected static boolean isValidOs() {
        String osName = System.getProperty(OS_NAME, "");
        String lowerOs = osName.toLowerCase();
        if (isWindows())
            return true;
        if (lowerOs.indexOf("linux") >= 0)
            return true;
        if (lowerOs.indexOf("mac") >= 0)
            return true;
        if (lowerOs.indexOf("unix") >= 0)
            return true;
        return false;
    }

    protected static boolean isValidJava(JavaVersionInfo javaVersionInfo) {
        String lowerJava = javaVersionInfo.getVersion().toLowerCase();
        if (lowerJava.startsWith("1.2"))
            return true;
        if (lowerJava.startsWith("1.3"))
            return true;
        if (lowerJava.startsWith("1.4"))
            return true;
        if (lowerJava.startsWith("1.5"))
            return true;
        return false;
    }

    protected static boolean isWindows() {
        boolean isWindows = false;
        String osName = System.getProperty(OS_NAME, "");
        if (osName.toLowerCase().indexOf("windows") >= 0) {
            isWindows = true;
        }
        return isWindows;
    }

    protected static boolean isMacintosh() {
        boolean isMacintosh = false;
        String osName = System.getProperty(OS_NAME, "");
        if (osName.toLowerCase().indexOf("mac") >= 0) {
            isMacintosh = true;
        }
        return isMacintosh;
    }

    protected static boolean isJDK141() {
        boolean isJDK141 = false;
        String javaVersion = System.getProperty(JavaVersionTester.JAVA_VERSION, "");
        if (javaVersion.toLowerCase().startsWith("1.4.1")) {
            isJDK141 = true;
        }
        return isJDK141;
    }

    protected static String getReadmeText(String targetDirectory) {
        File readmeFile = new File(targetDirectory, "README.txt");
        BufferedReader reader = null;
        StringBuffer buffer = new StringBuffer();
        try {
            reader = new BufferedReader(new FileReader(readmeFile));
            for (String s; (s = reader.readLine()) != null;) {
                buffer.append(s);
                buffer.append("\n");
            }
        } catch (FileNotFoundException fnfe) {
            fnfe.printStackTrace();
        } catch (IOException ioe) {
            ioe.printStackTrace();
        } finally {
            if (reader != null)
                try {
                    reader.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
        }
        return buffer.toString();
    }

    /**
     * Get the version info of an external (maybe other) jvm.
     * 
     * @param javaHome The java home of the external jvm. The /bin directory is assumed to be a direct child directory.
     * @return The versionInfo
     */
    protected static JavaVersionInfo getExternalJavaVersion(File javaHome) {
        JavaVersionInfo versionInfo = new JavaVersionInfo();

        File binDirectory = new File(javaHome, "bin");
        if (binDirectory.exists() && binDirectory.isDirectory()) {
            try {
                // launch the java command - temporary file will be written by the child process
                File tempFile = File.createTempFile("jython_installation", ".properties");
                if (tempFile.exists() && tempFile.canWrite()) {
                    String command[] = new String[5];
                    command[0] = binDirectory.getAbsolutePath() + File.separator + "java";
                    command[1] = "-cp";
                    command[2] = System.getProperty("java.class.path"); // our own class path should be ok here
                    command[3] = JavaVersionTester.class.getName();
                    command[4] = tempFile.getAbsolutePath();

                    ChildProcess childProcess = new ChildProcess(command, 10000); // 10 seconds
                    int errorCode = childProcess.run();
                    if (errorCode != NORMAL_RETURN) {
                        versionInfo.setErrorCode(errorCode);
                        versionInfo.setReason("abnormal return of the JavaVersionTester");
                    } else {
                        Properties tempProperties = new Properties();
                        tempProperties.load(new FileInputStream(tempFile));
                        fillJavaVersionInfo(versionInfo, tempProperties);
                    }
                } else {
                    versionInfo.setErrorCode(ERROR_RETURN);
                    versionInfo.setReason("problems creating temp file " + tempFile.getAbsolutePath());
                }
            } catch (IOException e) {
                versionInfo.setErrorCode(ERROR_RETURN);
                versionInfo.setReason("IOException: " + e.getMessage());
            }
        } else {
            versionInfo.setErrorCode(ERROR_RETURN);
            versionInfo.setReason(binDirectory.getAbsolutePath() + " is not an existing directory");
        }

        return versionInfo;
    }

    protected static void fillJavaVersionInfo(JavaVersionInfo versionInfo, Properties properties) {
        versionInfo.setVersion(properties.getProperty(JavaVersionTester.JAVA_VERSION));
        versionInfo.setSpecificationVersion(properties.getProperty(JavaVersionTester.JAVA_SPECIFICATION_VERSION));
        versionInfo.setVendor(properties.getProperty(JavaVersionTester.JAVA_VENDOR));
    }

    protected static class JavaVersionInfo {
        private String _version;
        private String _specificationVersion;
        private String _vendor;
        private int _errorCode;
        private String _reason;

        protected JavaVersionInfo() {
            _version = EMPTY;
            _specificationVersion = EMPTY;
            _errorCode = NORMAL_RETURN;
            _reason = EMPTY;
        }

        protected void setVersion(String version) {
            _version = version;
        }

        protected void setSpecificationVersion(String specificationVersion) {
            _specificationVersion = specificationVersion;
        }

        protected void setVendor(String vendor) {
            _vendor = vendor;
        }

        protected void setErrorCode(int errorCode) {
            _errorCode = errorCode;
        }

        protected void setReason(String reason) {
            _reason = reason;
        }

        protected String getVersion() {
            return _version;
        }

        protected String getSpecificationVersion() {
            return _specificationVersion;
        }

        protected String getVendor() {
            return _vendor;
        }

        protected int getErrorCode() {
            return _errorCode;
        }

        protected String getReason() {
            return _reason;
        }
    }

    //
    // private methods
    //

    private static boolean useGUI(InstallerCommandLine commandLine) {
        if (commandLine.hasConsoleOption() || commandLine.hasSilentOption()) {
            return false;
        }
        if (Boolean.getBoolean("java.awt.headless")) {
            return false;
        }
        try {
            GraphicsEnvironment.getLocalGraphicsEnvironment();
            return true;
        } catch (Throwable t) {
            return false;
        }
    }

}