import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.dayfi.test"
            resValue(type = "string", name = "app_name", value = "dayfi Test")
        }
        create("pilot") {
            dimension = "flavor-type"
            applicationId = "com.dayfi.pilot"
            resValue(type = "string", name = "app_name", value = "dayfi Pilot")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.dayfi.prod"
            resValue(type = "string", name = "app_name", value = "dayfi")
        }
    }
}