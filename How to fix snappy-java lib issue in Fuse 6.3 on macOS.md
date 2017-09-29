## Symptom

You try to install some of Camel components and get following error regarding snappy java library.
```
org.apache.karaf.shell.console - 2.4.0.redhat-630283 | Exception caught while executing command
java.lang.Exception: Could not start bundle mvn:org.xerial.snappy/snappy-java/1.1.0.1-redhat.002 in feature(s) camel-kafka-2.17.0.redhat-630283, camel-hdfs2-2.17.0.redhat-630283, camel-avro-2.17.0.redhat-630283: Activator start error in bundle org.xerial.snappy.snappy-java [371].
	at org.apache.karaf.features.internal.FeaturesServiceImpl.doInstallFeatures(FeaturesServiceImpl.java:550)[11:org.apache.karaf.features.core:2.4.0.redhat-630283]
	at org.apache.karaf.features.internal.FeaturesServiceImpl$1.call(FeaturesServiceImpl.java:432)[11:org.apache.karaf.features.core:2.4.0.redhat-630283]
	at java.util.concurrent.FutureTask.run(FutureTask.java:266)[:1.8.0_144]
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)[:1.8.0_144]
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)[:1.8.0_144]
	at java.lang.Thread.run(Thread.java:748)[:1.8.0_144]
Caused by: org.osgi.framework.BundleException: Activator start error in bundle org.xerial.snappy.snappy-java [371].
	at org.apache.felix.framework.Felix.activateBundle(Felix.java:2204)[org.apache.felix.framework-4.4.1.jar:]
	at org.apache.felix.framework.Felix.startBundle(Felix.java:2072)[org.apache.felix.framework-4.4.1.jar:]
	at org.apache.felix.framework.BundleImpl.start(BundleImpl.java:976)[org.apache.felix.framework-4.4.1.jar:]
	at org.apache.felix.framework.BundleImpl.start(BundleImpl.java:963)[org.apache.felix.framework-4.4.1.jar:]
	at org.apache.karaf.features.internal.FeaturesServiceImpl.doInstallFeatures(FeaturesServiceImpl.java:546)[11:org.apache.karaf.features.core:2.4.0.redhat-630283]
	... 5 more
Caused by: java.lang.UnsatisfiedLinkError: no libsnappyjava.dylib in java.library.path
	at java.lang.ClassLoader.loadLibrary(ClassLoader.java:1867)[:1.8.0_144]
	at java.lang.Runtime.loadLibrary0(Runtime.java:870)[:1.8.0_144]
	at java.lang.System.loadLibrary(System.java:1122)[:1.8.0_144]
	at org.xerial.snappy.SnappyBundleActivator.start(SnappyBundleActivator.java:52)
	at org.apache.felix.framework.util.SecureAction.startActivator(SecureAction.java:645)
	at org.apache.felix.framework.Felix.activateBundle(Felix.java:2154)
	... 9 more
  ```
  
  ## Diagnosis
  It is related to a Java call `System.mapLibraryName()`. If you call `System.mapLibraryName("snappyjava")`, it will prepend "lib" at the beginning of string and based on OS to choose extension. This will use `.so` on Linux and `.dll` on Windows. MAC OS support multiple extensions, and the `mapLibraryName` method can only support one by design. In **Java 6** `.jnilib` is used and **Java 7+** starts to use `.dylib` instead. The version `1.1.0.1-redhat.002` of **snappy-java** only packages file `libsnappyjava.jnilib`, hence the error.
  
  ## Treatment
  1. Extract 'jboss-fuse-6.3.0.redhat-283/system/org/xerial/snappy/snappy-java/1.1.0.1-redhat.002/snappy-java-1.1.0.1-redhat.002.jar'.
  2. Rename `snappy-java-1.1.0.1-redhat.002/org/xerial/snappy/native/Mac/x86_64/libsnappyjava.jnilib` file to `libsnappyjava.dylib` (If you're using macOS 32-Bit then rename the file in `../x86` directory instead).
  3. Open `snappy-java-1.1.0.1-redhat.002/META-INF/MANIFEST.MF` in a text editor and rename `libsnappyjava.jnilib` to `libsnappyjava.dylib` in `Bundle-NativeCode:` section.
  4. Repackage the extracted `jboss-fuse-6.3.0.redhat-283` directory to `.jar` file and put it back to the same path.
