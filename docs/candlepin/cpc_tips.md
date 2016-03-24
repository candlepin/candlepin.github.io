---
title: Using cpc
---
{% include toc.md %}

# Tips on using `cpc` tool

## Register a consumer
```
         command  name      type   uuid facts               user  owner
         -------- --------- ------ ---- ------------------- ----- --------
   ./cpc register mymachine system ""   '{"key" => "fact"}' admin admin
```

## Import a manifest
```
         command  owner_key filename                               force (optional)
         -------- --------- ---------                              -----------------
   ./cpc import   orgB      /tmp/candlepin-export-91634/export.zip {true|false}
```

## Create a new owner
```
         command      owner_key
         --------     ---------
   ./cpc create_owner orgA
```

## Create a new user
```
         command      login    password  superadmin (t|f)
         --------     -------- --------- -----
   ./cpc create_user  fooUser  password  {true|false}
```

## Pass in an array
```
   ./cpc some_command '["123", "abc"]'
```

## Pass in a parameters map
```
   ./cpc list_entitlements '{:uuid => "8a8b66f738fc86640138fc8682e7003c"}'
```

## Consume a pool (bind/subscribe)
```
       command      pool_id                          params
       ------------ -------------------------------- --------------------------------- 
 ./cpc consume_pool 8a8b64a33aae1f0f013aae201d700969 '{:quantity => "5", :uuid => "f12f1552-7c4f-4009-a246-3f11388a84c0"}'
```

## Export consumer (Manifest)
```
       command         destination dir  params                                      optional
       ------------    ---------------- ---------------------------------           --------------------
 ./cpc export_consumer /tmp/foo         --uuid f12f1552-7c4f-4009-a246-3f11388a84c0 ['{:cdn_key=>cdnkey, :webapp_prefix=>URL, :api_url=>URL}']
```

## Create Consumer Type
```
       command              label  manifest (defaults to false)
       ------------         ------ ----------------------------- 
 ./cpc create_consumer_type SAM    true
```

## Create a CDN object
```
       command                         private key name     url
       ------------                    ----------- -------- -------------------- 
 ./cpc create_content_delivery_network testkey     zeus-cdn "https://transam.rdu.redhat.com:8088"
```
