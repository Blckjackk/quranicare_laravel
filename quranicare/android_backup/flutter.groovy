def flutterProjectRoot = rootProject.projectDir.parentFile
def localProperties = new Properties()
def localPropertiesFile = new File(flutterProjectRoot, "local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader("UTF-8") { reader ->
        localProperties.load(reader)
    }
}

def flutterSdkPath = localProperties.getProperty("flutter.sdk")
if (flutterSdkPath == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}
flutterSdkPath = flutterSdkPath.replace('\\', '/')

apply from: new File(flutterSdkPath, "packages/flutter_tools/gradle/flutter.gradle")
