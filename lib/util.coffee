request = require 'request'
targz = require 'tar.gz'
zip = require 'adm-zip'
fs = require 'fs'
Q = require 'q'
crypto = require 'crypto'
urlUtil = require 'url'

module.exports = (grunt) ->

  compress = require('grunt-contrib-compress/tasks/lib/compress')(grunt)
  _ = require('lodash')
  _s = require('underscore.string');

  upload = (data, url, credentials, headers, isFile = true) ->
    deferred = Q.defer()

    options = _.assign {method: 'PUT', url: url, headers: headers}
    if credentials.username
      options = _.assign options, {auth: credentials}

    grunt.verbose.writeflags options

    if isFile
      file = fs.createReadStream(data)
      file.pipe(request.put(options, (error, response) ->
        if error
          deferred.reject {message: 'Error making http request: ' + error}
        else if response.statusCode is 201
          deferred.resolve()
        else
          deferred.reject {message: 'Request received invalid status code: ' + response.statusCode}
      ))
    else
      deferred.resolve()

    deferred.promise

  publishFile = (options, filename, urlPath, parameters) ->
    deferred = Q.defer()

    generateHashes(options.path + filename).then (hashes) ->

      url = urlPath + filename + parameters
      length = fs.statSync(options.path + filename).size
      headers = {"X-Checksum-Sha1": hashes.sha1, "X-Checksum-Md5": hashes.md5, "Content-Length": length}
      promises = [
        upload options.path + filename, url, options.credentials, headers
      ]

      Q.all(promises).then () ->
        deferred.resolve()
      .fail (error) ->
          deferred.reject error
    .fail (error) ->
        deferred.reject error

    deferred.promise

  generateHashes = (file) ->
    deferred = Q.defer()

    md5 = crypto.createHash 'md5'
    sha1 = crypto.createHash 'sha1'

    stream = fs.ReadStream file

    stream.on 'data', (data) ->
      sha1.update data
      md5.update data

    stream.on 'end', (data) ->
      hashes =
        md5: md5.digest 'hex'
        sha1: sha1.digest 'hex'
      deferred.resolve hashes

    stream.on 'error', (error) ->
      deferred.reject error

    deferred.promise

  return {

  ###*
  * Package a path to artifact
  * @param {ArtifactoryArtifact} artifact The artifactory artifact to publish to artifactory
  * @param {String} path The path to publish to artifactory
  *
  * @return {Promise} returns a Q promise to be resolved when the artifact is done being packed
  ###
  package: (artifact, files, options) ->
    deferred = Q.defer()
    filename = artifact.buildArtifactUri()
    archive = "#{options.path}#{filename}"

    if(_s.endsWith(archive, '.war') or _s.endsWith(archive, '.jar'))
      mode = 'zip'
    else
      compress.options = {}
      mode = compress.autoDetectMode(archive)

    compress.options =
      archive: archive
      mode: mode

    compress.tar files, () ->
      deferred.resolve()

    deferred.promise


  ###*
  * Publish a path to artifactory
  * @param {ArtifactoryArtifact} artifact The artifactory artifact to publish to artifactory
  * @param {Object} extra options
  *
  * @return {Promise} returns a Q promise to be resolved when the artifact is done being published
  ###
  publish: (artifact, options) ->
    filename = artifact.buildArtifactUri()
    parameters = if options.parameters then ';' + options.parameters.join(';') else ''

    return publishFile(options, filename, artifact.buildUrlPath(), parameters)
  }
