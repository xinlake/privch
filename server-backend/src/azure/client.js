const ip4Pattern = /^(\d{1,3}\.){3}\d{1,3}$/;
const ip4PrivatePattern = /^(10(\.[0-9]{1,3}){3}|172\.(1[6-9]|2[0-9]|3[0-1])(\.[0-9]{1,3}){2}|192\.168(\.[0-9]{1,3}){2})$/;

function getClientIp(requestHeaders) {
    const clientIpKeys = [
        "x-forwarded-for",
        "client-ip"
    ];

    for(const key of clientIpKeys) {
        const clientIp = requestHeaders.get(key)?.split(":")[0];
        if (clientIp && ip4Pattern.test(clientIp) && !ip4PrivatePattern.test(clientIp)) {
            return clientIp;
        }
    }

    return null;
}

module.exports = { getClientIp };
