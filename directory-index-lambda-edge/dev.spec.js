import test from 'ava';
import lambda from './dev';

const callback = (context=null, req) => req;

test('Handles /', t => {
	// mock params
    const event = {
        Records: [
            {
                cf: {
                    request: {
                        uri: '/'
                    }
                }
            }
        ]
    }
    const request = lambda.handler(event, null, callback);
    t.is(request.uri, '/index.html');
});

test('Handles Agent docs', t => {
	// mock params
    const event = {
        Records: [
            {
                cf: {
                    request: {
                        uri: '/agent'
                    }
                }
            }
        ]
    }
    const request = lambda.handler(event, null, callback);
    t.is(request.status, '302');
    t.is(request.headers.location[0].value.indexOf('agent/index.html') > 0, true);
});

test('Handles API docs', t => {
	// mock params
    const event = {
        Records: [
            {
                cf: {
                    request: {
                        uri: '/api'
                    }
                }
            }
        ]
    }
    const request = lambda.handler(event, null, callback);
    t.is(request.status, '302');
    t.is(request.headers.location[0].value.indexOf('api/index.html') > 0, true);
});

test('Handles Matlab docs', t => {
	// mock params
    const event = {
        Records: [
            {
                cf: {
                    request: {
                        uri: '/matlab'
                    }
                }
            }
        ]
    }
    const request = lambda.handler(event, null, callback);
    t.is(request.status, '302');
    t.is(request.headers.location[0].value.indexOf('matlab/index.html') > 0, true);
});

test('Handles Python docs', t => {
	// mock params
    const event = {
        Records: [
            {
                cf: {
                    request: {
                        uri: '/python'
                    }
                }
            }
        ]
    }
    const request = lambda.handler(event, null, callback);
    t.is(request.status, '302');
    t.is(request.headers.location[0].value.indexOf('python/index.html') > 0, true);
});

test('Handles missing request objects', t => {
    // mock params
    const event = {
        Records: [
            {
                cf: {}
            }
        ]
    }
    const request = lambda.handler(event, null, callback);
    t.deepEqual(request, {});

    // mock params
    const event2 = {
        Records: []
    }
    const request2 = lambda.handler(event2, null, callback);
    t.deepEqual(request2, {});

    // mock params
    const event3 = {
        Records: []
    }
    const request3 = lambda.handler(event3, null, callback);
    t.deepEqual(request3, {});
});
