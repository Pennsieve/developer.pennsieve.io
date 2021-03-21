'use strict';

// Supported values for fn: https://developer.mozilla.org/en-US/docs/Web/API/Console
var logger = function(fn, txt) {
  try {
    var msg = '{"' + fn + '": "' + txt + '"}';
    var json = JSON.parse(msg);
    if (typeof console[fn] === 'function') {
      console[fn](json);
    }
  } catch (ex) {
    console.error('JSON parsing exception', ex);
  }
}

var getRequest = function(obj) {
  var list = obj.Records;
  var firstItem;
  if (Array.isArray(list)) {
    firstItem = list[0];
    if (firstItem && firstItem.cf && firstItem.cf.request) {
      return firstItem.cf.request;
    }
    logger('error', 'cf.request not found');
  }
  logger('error', 'event.Records not found');
  return {}
}

var setLocation = function(uri) {
  var response = {
    status: '302',
    statusDescription: 'Found',
    headers: {
      location: [{
        key: 'Location',
        value: 'https://developer.pennsieve.io' + uri,
      }],
    },
  };
  return response;
}

var updateRequest = function(olduri, request) {
  var sites = [
    'agent',
    'api',
    'matlab',
    'python',
  ];
  var endsWith = sites.filter(site => olduri.endsWith(site));
  if (endsWith.length > 0) {
    var path = '/' + endsWith[0] + '/index.html';
    logger('info', 'Redirecting to: ' + path);
    return setLocation(path);
  }
  logger('info', 'Request uri: ' + request.uri);
  return request;
}

exports.handler = (event, context, callback) => {

    // Source: https://aws.amazon.com/blogs/compute/implementing-default-directory-indexes-in-amazon-s3-backed-amazon-cloudfront-origins-using-lambdaedge/
    // Extract the request from the CloudFront event that is sent to Lambda@Edge
    var request = getRequest(event);

    // Extract the URI from the request
    var olduri = request.uri;

    // Short circuit if uri does not exist
    if (!olduri) {
      return callback(null, request);
    }

    // Match any '/' that occurs at the end of a URI. Replace it with a default index
    var newuri;
    if (/\/$/.test(olduri)) {
      newuri = olduri.replace(/\/$/, '\/index.html');
      // Log the URI as received by CloudFront and the new URI to be used to fetch from origin
      logger('info', 'Old URI: ' + olduri);
      logger('info', 'New URI: ' + newuri);
      // Replace the received URI with the URI that includes the index page
      request.uri = newuri;
    } else {
      // Update the request object
      request = updateRequest(olduri, request);
    }

    // Return to CloudFront
    return callback(null, request);

};
