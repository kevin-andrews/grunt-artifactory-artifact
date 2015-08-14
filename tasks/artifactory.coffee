"use strict"
Q = require 'q'

module.exports = (grunt) ->
  ArtifactoryArtifact = require('../lib/artifactory-artifact')(grunt)
  util = require('../lib/util')(grunt)
  # shortcut to Lodash
  _ = require('lodash')

  grunt.registerMultiTask 'artifactory', 'Download an artifact from artifactory', ->
    done = @async()

    # defaults
    options = this.options
      url: ''
      base_path: 'artifactory'
      repository: ''
      versionPattern: '%a-%v%c.%e'
      username: ''
      password: ''

    processes = []

    if @args.length and _.contains @args, 'publish'
      artifactCfg = {}
      _.assign artifactCfg, ArtifactoryArtifact.fromString(options.id) if options.id
      _.assign artifactCfg, options

      artifact = new ArtifactoryArtifact artifactCfg
      deferred = Q.defer()
      util.package(artifact, @files, { path: options.path }).then () ->
          util.publish(artifact, { path: options.path, credentials: { username: options.username, password: options.password }, parameters: options.parameters}).then ()->
              deferred.resolve()
          .fail (err) ->
              deferred.reject(err)
      .fail (err) ->
          deferred.reject(err)
      processes.push deferred.promise

    Q.all(processes).then(() ->
      done()
    ).fail (err) ->
      grunt.fail.warn err
