const { ContainerClient, BlobServiceClient, StorageSharedKeyCredential } = require("@azure/storage-blob");
const stream = require("./stream");

async function list(storageAccount, storageKey, storageContainer) {
    // Use StorageSharedKeyCredential with storage account and account key
    // StorageSharedKeyCredential is only available in Node.js runtime, not in browsers
    const sharedKeyCredential = new StorageSharedKeyCredential(storageAccount, storageKey);
  
    // list blobs
    const containerClient = new ContainerClient(
        `https://${storageAccount}.blob.core.windows.net/${storageContainer}`,
        sharedKeyCredential
    );
    
    const blobs = [];
    for await (const blob of containerClient.listBlobsFlat()) {
        const blockBlobClient = containerClient.getBlockBlobClient(blob.name);        
        const snapshotResponse = await blockBlobClient.createSnapshot();
        const blobSnapshotClient = blockBlobClient.withSnapshot(snapshotResponse.snapshot);
        const response = await blobSnapshotClient.download(0);
        
        blobs.push({ 
            name: blob.name, 
            "content": (await stream.streamToBuffer(response.readableStreamBody)).toString(),
            "last-modified": blob.properties.lastModified
        });
    }

    return blobs;
}

async function put(storageAccount, storageKey, storageContainer, blobName, content) {
    // Use StorageSharedKeyCredential with storage account and account key
    // StorageSharedKeyCredential is only available in Node.js runtime, not in browsers
    const sharedKeyCredential = new StorageSharedKeyCredential(storageAccount, storageKey);
  
    const containerClient = new ContainerClient(
      `https://${storageAccount}.blob.core.windows.net/${storageContainer}`,
      sharedKeyCredential
    );
  
    // Create the container if not exist
    await containerClient.createIfNotExists();
  
    // Create a blob
    const blockBlobClient = containerClient.getBlockBlobClient(blobName);
    const uploadBlobResponse = await blockBlobClient.upload(content, Buffer.byteLength(content));

    return uploadBlobResponse.lastModified;
}

module.exports = { list, put };
