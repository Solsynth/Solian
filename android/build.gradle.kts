import com.android.build.api.dsl.ApplicationExtension
import com.android.build.api.dsl.LibraryExtension
import com.android.build.gradle.BaseExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
// androidx.core 1.19.0+ requires AGP 9.1.0+; pin until AGP is upgraded.
subprojects {
    configurations.configureEach {
        resolutionStrategy {
            force("androidx.core:core:1.18.0", "androidx.core:core-ktx:1.18.0")
        }
    }
}
subprojects {
    plugins.withId("com.android.library") {
        extensions.findByName("android")?.let { ext ->
            if (ext is BaseExtension) {
                ext.compileSdkVersion(37)
            }
        }
    }

    plugins.withId("com.android.application") {
        extensions.findByName("android")?.let { ext ->
            if (ext is BaseExtension) {
                ext.compileSdkVersion(37)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
