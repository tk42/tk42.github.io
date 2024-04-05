---
title: Firestore import/export by JSON
date: 2022-10-29
tags: 
publish: true
---
I would like to start by saying that Firestore is the best useful NoSQL in cloud services. The SDK of Firestore has been supported by many programming languages and it can be used easily by your service account.

But there is one trouble thing. To export inside data from Firestore, we have to save it as LevelDB in cloud storage, and vice versa. LevelDB is one of the finest Key-Value-Store, but its data are saved as binary, so we can’t see inside easily. Surprisingly, the GCP console on the web can’t see any exported collections from Firestore. Moreover, changing inside data is tough, such as renaming a collection name.

Then I started googling some easy tools for handling inside data in Firestore. Though there is a good tool, I have to clone the repository and build up an environment for it. Damn it! So, I wrapped it in a docker container and stored the container registry.

[GitHub - tk42/firestore-import-export: An application that can help you to backup and restore from Cloud Firestore | Firebase](https://github.com/tk42/firestore-import-export?source=post_page-----b3c33e4d4779--------------------------------)

You don’t need to clone this repository. All you have to do is to write `docker-compose.yml` anywhere you want to export/import data, as follows

```yaml
services:  
  export:  
    image: "ghcr.io/tk42/firestore-import-export"  
    command: ["node", "export.js", "{CollectionName}"]  
    volumes:  
      - ./serviceAccountKey.json:/home/serviceAccountKey.jsonimport:  
    image: "ghcr.io/tk42/firestore-import-export"  
    command: ["node", "import.js", "./import-to-firestore.json"]  
    volumes:  
      - ./serviceAccountKey.json:/home/serviceAccountKey.json  
      - ./import-to-firestore.json:/home/import-to-firestore.json
```

Before using it, in the same directory, you have to save `serviceAccountKey.json`which has permission to access your Firestore.

For example, if you want to export a collection “MyCollection” in your Firestore, you have to replace `{CollectionName}` above it with `MyCollection` then you can execute

```bash
docker-compose up export
```

Then you can see the exported data as JSON in your Firestore console.

And if you want to import JSON data, you have to rename it with “import-to-firestore.json” and then you can execute 

```bash
docker-compose up import
```

Then you can see the newly imported data in your Firestore console.

Try it!