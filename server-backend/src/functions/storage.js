const { app } = require('@azure/functions');
const azStorage = require( "../azure/storage");
const blake = require('../blake/blake2b');
const ed25519 = require('../ed25519/ed25519');

const privchVersion = "2024.1";
const privateIpRegex = /^(10(\.[0-9]{1,3}){3}|172\.(1[6-9]|2[0-9]|3[0-1])(\.[0-9]{1,3}){2}|192\.168(\.[0-9]{1,3}){2})$/;

// storage account name and shared key
if (!process.env.PRIVCH_STORAGE_ACCOUNT || 
    !process.env.PRIVCH_STORAGE_API_KEY || 
    !process.env.PRIVCH_ED25519_PUB) {
    require("dotenv").config();
}

const storageAccount = (process.env.PRIVCH_STORAGE_ACCOUNT || process.env.PRIVCH_STORAGE_ACCOUNT_D)
    ?.replace(/\s+/g, "");
const storageKey = (process.env.PRIVCH_STORAGE_API_KEY || process.env.PRIVCH_STORAGE_API_KEY_D)
    ?.replace(/\s+/g, "");
const storageContainer = (process.env.PRIVCH_STORAGE_CONTAINER || "private-channel")
    ?.replace(/\s+/g, "");

const ed25519Pub = (process.env.PRIVCH_ED25519_PUB || process.env.PRIVCH_ED25519_PUB_D)
    ?.replace(/\s+/g, "");

if (!storageAccount || !storageKey || !ed25519Pub) {
    app.http('storage', {
        methods: ['GET', 'POST'],
        authLevel: 'anonymous',
        handler: async (request, context) => {
            return {
                status: 500,
                headers: {'content-type': 'text/plain;charset=UTF-8'},
                body: 'Configuration Error'
            };
        }
    });

    return;
}

app.http('storage', {
    methods: ['GET', 'POST'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
        let clientIp = request.headers.get("x-forwarded-for")?.split(":")[0];
        if (!clientIp || privateIpRegex.test(clientIp)) {
            clientIp = request.headers.get("client-ip")?.split(":")[0];
            if (!clientIp || privateIpRegex.test(clientIp)) {
                return {
                    status: 200,
                    headers: {'content-type': 'text/plain;charset=UTF-8'},
                    body: 'Access Denied'
                };
            }
        }

        const jsonBody = await request.json();

        // validate HTTP request without providing details to the client
        if (!clientIp || !jsonBody) {
            return {
                status: 200,
                headers: {'content-type': 'text/plain;charset=UTF-8'},
                body: 'Access Denied'
            };
        }

        const signature = jsonBody["signature"];
        const action = jsonBody["action"];
    
        // validate parameters without providing details to the client
        if (!signature || !action) {
            return {
                status: 200,
                headers: {'content-type': 'text/plain;charset=UTF-8'},
                body: 'Access Denied'
            };
        }

        // verify client signature
        let validSignature = false;

        try {
            validSignature = await ed25519.verifyAsync(
                Buffer.from(signature, 'base64').toString("hex"),
                Buffer.from(blake.blake2bHex(clientIp, null, 64), 'utf8').toString("hex"),
                Buffer.from(ed25519Pub, 'base64').toString("hex")
            );
        } catch (error) {
            validSignature = false;
        }

        if (!validSignature) {
            return {
                status: 200,
                headers: {'content-type': 'text/plain;charset=UTF-8'},
                body: 'Access Denied'
            };
        }

        // process request
        const jsonRespond = {
            "privch-version": privchVersion
        };
        
        // list
        if (action == "list") {
            try {
                jsonRespond.result = await azStorage.list(
                    storageAccount, 
                    storageKey,
                    storageContainer
                );
            } catch (error) {
                jsonRespond.result = error;
            }
        }
        // put
        else if(action == "put") {
            const blobName = jsonBody["blob-name"];
            const content =  jsonBody["content"];
            if (blobName && content) {
                try {
                    jsonRespond.result = await azStorage.put(
                        storageAccount,
                        storageKey,
                        storageContainer,
                        blobName,
                        content
                    );
                } catch (error) {
                    jsonRespond.result = error;
                }
            }
        }

        return {
            status: 200,
            headers: {'content-type': 'application/json;charset=UTF-8'},
            jsonBody: jsonRespond
        }
    }
});
