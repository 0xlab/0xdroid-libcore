/*
 * Copyright (C) 2009 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package dalvik.runner;

import java.io.File;
import java.io.PrintStream;
import java.util.List;
import java.util.logging.Logger;

/**
 * Execute tests on a Dalvik VM using an Android device or emulator.
 */
final class DeviceDalvikVm extends Vm {
    private static final Logger logger = Logger.getLogger(DeviceDalvikVm.class.getName());

    DeviceDalvikVm(Integer debugPort, long timeoutSeconds, File sdkJar, PrintStream tee,
            File localTemp, List<String> additionalVmArgs,
            boolean cleanBefore, boolean cleanAfter, File runnerDir) {
        super(new EnvironmentDevice(cleanBefore, cleanAfter, debugPort, localTemp, runnerDir),
                timeoutSeconds, sdkJar, tee, additionalVmArgs);
    }

    private EnvironmentDevice getEnvironmentDevice() {
        return (EnvironmentDevice) environment;
    }

    @Override protected void postCompileTestRunner() {
        // TODO: does this really need to be a special case?
        postCompile("testrunner", environment.testRunnerClassesDir());

        // dex everything on the classpath and push it to the device.
        for (File classpathElement : testClasspath.getElements()) {
            String name = basenameOfJar(classpathElement);
            logger.fine("dex and push " + name);
            // make the local dex (inside a jar)
            // TODO: this is *really* expensive. we need a cache!
            File outputFile = getEnvironmentDevice().testDir(name + ".jar");
            new Dx().dex(outputFile, Classpath.of(classpathElement));
            // push the local dex to the device
            getEnvironmentDevice().adb.push(outputFile, deviceDexFile(name));
        }
    }

    private String basenameOfJar(File jarFile) {
        return jarFile.getName().replaceAll("\\.jar$", "");
    }

    @Override protected void postCompileTest(TestRun testRun) {
        postCompile(testRun.getQualifiedName(), environment.testClassesDir(testRun));
    }

    private void postCompile(String name, File dir) {
        logger.fine("dex and push " + name);

        // make the local dex (inside a jar)
        File localDex = new File(dir.getPath() + ".jar");
        new Dx().dex(localDex, Classpath.of(dir));

        // post the local dex to the device
        File deviceDex = deviceDexFile(name);
        getEnvironmentDevice().adb.push(localDex, deviceDex);
    }

    private File deviceDexFile(String name) {
        return new File(getEnvironmentDevice().runnerDir, name + ".jar");
    }

    @Override protected VmCommandBuilder newVmCommandBuilder(
            File workingDirectory) {
        // ignore the working directory; it's device-local and we can't easily
        // set the working directory for commands run via adb shell.
        // TODO: we only *need* to set ANDROID_DATA on production devices.
        // We set "user.home" to /sdcard because code might reasonably assume it can write to
        // that directory.
        return new VmCommandBuilder()
                .vmCommand("adb", "shell", "ANDROID_DATA=/sdcard", "dalvikvm")
                .vmArgs("-Duser.home=/sdcard")
                .vmArgs("-Duser.name=root")
                .vmArgs("-Duser.language=en")
                .vmArgs("-Duser.region=US")
                .vmArgs("-Djavax.net.ssl.trustStore=/system/etc/security/cacerts.bks")
                .temp(getEnvironmentDevice().testTemp);
    }

    @Override protected Classpath getRuntimeSupportClasspath(TestRun testRun) {
        Classpath classpath = new Classpath();
        classpath.addAll(deviceDexFile(testRun.getQualifiedName()));
        classpath.addAll(deviceDexFile("testrunner"));
        for (File testClasspathElement : testClasspath.getElements()) {
            classpath.addAll(deviceDexFile(basenameOfJar(testClasspathElement)));
        }
        return classpath;
    }
}
