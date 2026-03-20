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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Kotlin/Java targets must match per-module (Kotlin validation is strict).
// Most Flutter/AGP modules are on Java 17, but some older plugins are still on 1.8.
subprojects {
    val kotlinTarget = when (project.name) {
        "receive_sharing_intent" -> org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8
        else -> org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }

    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(kotlinTarget)
        }
    }
}