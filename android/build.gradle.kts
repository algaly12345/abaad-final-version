allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// A handful of old, unmaintained plugins were previously only listed under
// dependency_overrides, so their native Android modules were never actually
// compiled — the incompatibilities below were latent. Now that they're real
// dependencies (see pubspec.yaml), fix them up as they surface. Must run via
// plugins.withId (not afterEvaluate) so it applies before AGP creates variants.
subprojects {
    plugins.withId("com.android.library") {
        val androidExt = extensions.findByName("android") as? com.android.build.gradle.LibraryExtension
            ?: return@withId

        // AGP 8+ requires every library module to declare a namespace.
        // flutter_google_street_view (last published for AGP 4.1) never set one.
        if (project.name == "flutter_google_street_view" && androidExt.namespace == null) {
            androidExt.namespace = "zyz.flutter.plugin.flutter_google_street_view"
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
