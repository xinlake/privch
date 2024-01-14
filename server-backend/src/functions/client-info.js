const { app } = require('@azure/functions');

app.http('client-info', {
    methods: ['GET', 'POST'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
        const headersObject = {};
        for (const [key, value] of request.headers.entries()) {
            headersObject[key] = value;
        }

        return {
            status: 200,
            headers: {'content-type': 'application/json;charset=UTF-8'},
            jsonBody: headersObject
        };
    }
});
