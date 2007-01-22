package org.python.util.install;

import java.io.File;

import org.python.util.install.Installation.JavaVersionInfo;

import junit.framework.TestCase;

public class InstallationTest extends TestCase {

    public void testGetExternalJavaVersion() {
        File javaHome = new File(System.getProperty(JavaVersionTester.JAVA_HOME));
        JavaVersionInfo versionInfo = Installation.getExternalJavaVersion(javaHome);
        assertEquals(Installation.NORMAL_RETURN, versionInfo.getErrorCode());
        assertEquals("", versionInfo.getReason());
        assertTrue(versionInfo.getVersion().length() > 0);
        assertTrue(versionInfo.getSpecificationVersion().length() > 0);
        assertTrue(versionInfo.getVersion().startsWith(versionInfo.getSpecificationVersion()));
        assertNotNull(versionInfo.getVendor());
        assertNotSame("", versionInfo.getVendor());
    }

    public void testGetExternalJavaVersionWithError() {
        File javaHome = new File(System.getProperty("user.home"), "non_existing");
        JavaVersionInfo versionInfo = Installation.getExternalJavaVersion(javaHome);
        assertEquals(Installation.ERROR_RETURN, versionInfo.getErrorCode());
        String reason = versionInfo.getReason();
        assertTrue(reason.indexOf("directory") >= 0 || reason.indexOf("Verzeichnis") >= 0);
    }

    public void testGetExternalJavaVersionNoBinDirectory() {
        File javaHome = new File(System.getProperty("user.home"));
        JavaVersionInfo versionInfo = Installation.getExternalJavaVersion(javaHome);
        assertEquals(Installation.ERROR_RETURN, versionInfo.getErrorCode());
        String reason = versionInfo.getReason();
        assertTrue(reason.indexOf("directory") >= 0 || reason.indexOf("Verzeichnis") >= 0);
    }

    public void testGetExternalJavaVersionNoJavaInBinDirectory() {
        File javaHome = new File(System.getProperty("user.home"));
        File binDir = new File(javaHome, "bin");
        assertFalse(binDir.exists());
        try {
            assertTrue(binDir.mkdirs());
            JavaVersionInfo versionInfo = Installation.getExternalJavaVersion(javaHome);
            assertEquals(Installation.ERROR_RETURN, versionInfo.getErrorCode());
            assertTrue(versionInfo.getReason().indexOf("java") >= 0);
        } finally {
            if (binDir.exists()) {
                binDir.delete();
            }
        }
    }

    public void testIsValidJavaVersion() {
        JavaVersionInfo javaVersionInfo = new JavaVersionInfo();

        javaVersionInfo.setSpecificationVersion("1.1.9");
        assertFalse(Installation.isValidJava(javaVersionInfo));
        javaVersionInfo.setSpecificationVersion("1.2");
        assertTrue(Installation.isValidJava(javaVersionInfo));
        javaVersionInfo.setSpecificationVersion("1.3");
        assertTrue(Installation.isValidJava(javaVersionInfo));
        javaVersionInfo.setSpecificationVersion("1.4");
        assertTrue(Installation.isValidJava(javaVersionInfo));
        javaVersionInfo.setSpecificationVersion("1.5");
        assertTrue(Installation.isValidJava(javaVersionInfo));
        javaVersionInfo.setSpecificationVersion("1.6");
        assertTrue(Installation.isValidJava(javaVersionInfo));
        javaVersionInfo.setSpecificationVersion("1.7");
        assertTrue(Installation.isValidJava(javaVersionInfo));
    }

}
