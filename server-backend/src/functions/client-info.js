const { app } = require('@azure/functions');
const azClient = require('../azure/client');

app.http('client-info', {
    methods: ['GET', 'POST'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
        const respond = {};
        for (const [key, value] of request.headers.entries()) {
            respond[key] = value;
        }

        respond["privch-client-ip"] = azClient.getClientIp(request.headers);

        return {
            status: 200,
            headers: {'content-type': 'application/json;charset=UTF-8'},
            jsonBody: respond
        };
    }
});
