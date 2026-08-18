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
// Raise the compile SDK of any plugin that declares one too low for its own
// transitive androidx dependencies.
//
// The release build failed on this: flutter_map_tile_caching (the offline tile
// cache, ADR-13) pulls in objectbox_flutter_libs, which compiles against
// android-31, while twenty androidx libraries it depends on require 33 or 34.
// AGP treats that as an error, so `assembleRelease` cannot produce an APK at
// all — which is why it never showed up in `flutter test`.
//
// compileSdk is the safe one of the three to move: it decides which APIs are
// available when compiling, NOT which runtime behaviours the app opts into
// (targetSdk) and NOT which devices can install it (minSdk). Both are
// untouched, so the low-end Android floor this project targets is unaffected.
//
// Two placement rules, both learned the hard way:
//
//  * This must come BEFORE the evaluationDependsOn block below. That block
//    forces :app to evaluate, and registering afterEvaluate on an
//    already-evaluated project throws "Cannot run Project.afterEvaluate(Action)
//    when the project is already evaluated."
//  * :app is skipped outright — it takes its compileSdk from the Flutter
//    tooling, and it is the one project guaranteed to be evaluated early.
//
// The reads are fail-soft across AGP versions: com.android.library exposes the
// String `compileSdkVersion` ("android-31") while newer extensions expose the
// Int `compileSdk`. If neither can be read we raise anyway, because the
// failure being fixed is a compile SDK that is too low.
subprojects {
    if (path == ":app") return@subprojects
    afterEvaluate {
        val android = extensions.findByName("android") ?: return@afterEvaluate
        val declared = runCatching {
            android.withGroovyBuilder {
                (getProperty("compileSdk") as? Int)
                    ?: (getProperty("compileSdkVersion") as? String)
                        ?.substringAfter("android-")
                        ?.toIntOrNull()
            }
        }.getOrNull()
        if (declared == null || declared < 36) {
            runCatching { android.withGroovyBuilder { "compileSdkVersion"(36) } }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
