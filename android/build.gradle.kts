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
    project.evaluationDependsOn(":app")

    plugins.withId("com.android.library") {
        if (!project.plugins.hasPlugin("org.jetbrains.kotlin.android")) {
            project.apply(plugin = "org.jetbrains.kotlin.android")

            // Those same plugins also skip their `kotlinOptions` block under
            // AGP 9, so the force-applied Kotlin compiler defaults to the
            // JDK's target (e.g. 21) and clashes with their Java target
            // ("Inconsistent JVM-target compatibility"). Align Kotlin's
            // jvmTarget to whatever Java target the module declares.
            project.afterEvaluate {
                val javaTarget = project.tasks
                    .withType(org.gradle.api.tasks.compile.JavaCompile::class.java)
                    .map { it.targetCompatibility }
                    .firstOrNull() ?: "1.8"
                project.tasks
                    .withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java)
                    .configureEach {
                        compilerOptions.jvmTarget.set(
                            org.jetbrains.kotlin.gradle.dsl.JvmTarget.fromTarget(javaTarget)
                        )
                    }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
