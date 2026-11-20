import com.android.build.api.variant.ApplicationAndroidComponentsExtension
import com.android.build.api.variant.LibraryAndroidComponentsExtension
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

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
// androidx.core 1.19+ (required by flutter_local_notifications 23.x) needs
// compileSdk 37 and AGP 9.1+, so the dependency is no longer pinned back to
// 1.18. Force every plugin module up to compileSdk 37 as well. This must be
// registered before :app is evaluated below, otherwise the DSL is already
// finalized by the time the callbacks run.
subprojects {
    // finalizeDsl runs after the plugin's build script sets its own compileSdk,
    // but only if these callbacks were registered before :app is evaluated.
    plugins.withId("com.android.library") {
        extensions.getByType(LibraryAndroidComponentsExtension::class.java)
            .finalizeDsl {
                it.compileSdk = 37
                it.compileOptions.sourceCompatibility = JavaVersion.VERSION_17
                it.compileOptions.targetCompatibility = JavaVersion.VERSION_17
            }
    }

    plugins.withId("com.android.application") {
        extensions.getByType(ApplicationAndroidComponentsExtension::class.java)
            .finalizeDsl {
                it.compileSdk = 37
                it.compileOptions.sourceCompatibility = JavaVersion.VERSION_17
                it.compileOptions.targetCompatibility = JavaVersion.VERSION_17
            }
    }

    // AGP 9 defaults to Java 11, while many plugins still pin Kotlin to 1.8.
    // Keep every module's Kotlin target aligned with the Java target above.
    tasks.withType(KotlinCompile::class.java).configureEach {
        compilerOptions.jvmTarget.set(JvmTarget.JVM_17)
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
