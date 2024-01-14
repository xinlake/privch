# Armoury

[![Maven Central](https://img.shields.io/maven-central/v/dev.xinlake/armoury.svg?color=blue&style=flat-square)](https://search.maven.org/artifact/dev.xinlake/armoury)

The main purpose of this aar library is to support Flutter plugins, making it easier for Flutter
apps to interact with the Android platform, Armoury is also available on Maven Central.

# Using

1. Add central Maven repository for all modules, edit the `build.gradle` file located in the *root
   project directory*

``` gradle
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

Or, add central Maven repository for one module，edit the `build.gradle` located in the *module
directory*

``` gradle
repositories {
    mavenCentral()
}
```

2. Add dependency

``` gradle
implementation "dev.xinlake:armoury:1.1.6"
```

# Demonstration

The `ready` module is a demonstration of `armoury` library, refer to the source code of the `ready`
module for detailed usage.
