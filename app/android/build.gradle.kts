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

// Raise the compile SDK of any plugin that declares one too low for its own
// transitive androidx dependencies.
//
// The release build failed on this: flutter_map_tile_caching (the offline tile
// cache, ADR-13) pulls in objectbox_flutter_libs, which compiles against
// android-31, while twenty androidx libraries it depends on require 33 or 34.
// AGP treats that as an error, so `assembleRelease` cannot produce an APK at
// all — which is why this only ever showed up here and never in `flutter test`.
//
// compileSdk is the safe one of the three to move: it decides which APIs are
// available when compiling, NOT which runtime behaviours the app opts into
// (targetSdk) and NOT which devices can install it (minSdk). Both of those are
// untouched, so the low-end Android floor this project targets is unaffected.
//
// Guarded rather than blanket-applied: a plugin that already asks for 36 or
// higher is left alone, so this never silently downgrades one.
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.withGroovyBuilder {
            val declared = (getProperty("compileSdkVersion") as? String)
                ?.substringAfter("android-")
                ?.toIntOrNull()
            if (declared != null && declared < 36) {
                "compileSdkVersion"(36)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
