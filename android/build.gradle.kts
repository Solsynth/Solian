import com.android.build.api.variant.ApplicationAndroidComponentsExtension
import com.android.build.api.variant.LibraryAndroidComponentsExtension

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
    // finalizeDsl runs after the plugin's build script sets its own compileSdk
    // but before AGP consumes the DSL, so it can't be "too late".
    plugins.withId("com.android.library") {
        extensions.getByType(LibraryAndroidComponentsExtension::class.java)
            .finalizeDsl { it.compileSdk = 37 }
    }

    plugins.withId("com.android.application") {
        extensions.getByType(ApplicationAndroidComponentsExtension::class.java)
            .finalizeDsl { it.compileSdk = 37 }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
