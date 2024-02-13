const { app } = require('@azure/functions');
const azClient = require('../azure/client');

app.http('client-ip', {
    methods: ['GET', 'POST'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
        const query = request.query.get("q");
        
        // all data 
        if (query == "all") {
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

        // default respond
        return {
            status: 200,
            headers: {'content-type': 'text/plain;charset=UTF-8'},
            body: azClient.getClientIp(request.headers)
        };
    }
});
