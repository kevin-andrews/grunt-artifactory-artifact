# grunt-artifactory-artifact
Forked from grunt-artifactory-artifact https://github.com/leedavidr/grunt-artifactory-artifact
This is a publish-only version, fixing a few bugs from the original (e.g. parameters now work).
> Publish artifacts to a JFrog Artifactory artifact repository.
> Only works with Mac and Linux

## Why?
If you're using grunt for frontend development and Java for the backend, it is convenient to consolidate dependencies into one repository.

## Getting Started
This plugin requires Grunt `~0.4.0`

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```shell
npm install grunt-artifactory-publish --save-dev
```

or add the following to your package.json file:
```js
{
  "devDependencies": {
    "grunt-artifactory-publish": "0.8.0"
  }
}
```

Once the plugin has been installed, enabled it inside your Gruntfile with this line of JavaScript:

```js
grunt.loadNpmTasks('grunt-artifactory-publish');
```

## Artifactory publish task
The publish flag will run the publish config to package and push artifacts up to artifactory. It uses [grunt-contrib-compress](https://github.com/gruntjs/grunt-contrib-compress) so the file configuration will be the same.
_Run this task with the `grunt artifactory:target:publish` command._

### Examples
```js
artifactory: {
  options: {
    url: 'http://artifactory.google.com:8080',
    repository: 'jslibraries',
    username: 'admin',
    password: 'admin123'
  },
  client: {
    files: [
      { src: ['builds/**/*'] }
    ],
    options: {
      id: 'com.mycompany.js:built-artifact:tgz',
      version: 'my-version',
      path: 'dist/'
      parameters: [
        'build.name=built-artifact',
        'version=my-version',
        'vcs.revision=my-revision',
      ]
    }
  }
}
```

In this example the `id` config is used, but the version is dropped. It can be specified in the `id` config or specified in the `version` config. This makes it easier to set the version dynamically.

### Options

The options listed here are new or repurposed for publish

#### path
Type `String`

This defines the temporary path for the compressed artifact.

#### files
Type `Array`

#### parameters
Type 'Array'

This takes a list of parameters which will be listed in the file properties in Artifactory.

#### decompress
Type 'Boolean'

When 'true', the artifact will attempt to be decompressed. Defaults to 'true'. Currently supports extensions 'tgz','jar','zip', and 'war'.


This parameter comes from `grunt-contrib-compress`. You can read about it at [github.com/gruntjs/grunt-contrib-compress](https://github.com/gruntjs/grunt-contrib-compress).
There are some differences from the config on `grunt-contrib-compress`. First of all, `ext` is used from the artifact, so it doesn't need to be specified. `mode` is currently not supported. It will auto-configure based on the extension.

# Release History
* 2013-08-08  v0.2.0  Added support for publishing artifacts

----

Original grunt-nexus-artifact contributed by Nicholas Boll of [Rally Software](http://rallysoftware.com)
Forked grunt-artifactory-artifact contributed by David R. Lee (http://www.twitter.com/david_r_lee)
