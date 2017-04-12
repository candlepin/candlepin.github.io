---
title: Extending A Manifest
---


# Extending A Manifest

In some scenarios, it may be desirable to have Candlepin add custom files to a manifest. Candlepin facilitates the extension of a manifest by allowing the configuration of a [ManifestExtensionAdapter](https://github.com/candlepin/candlepin/blob/master/server/src/main/java/org/candlepin/ManifestExtensionAdapter.java) implementation.

Custom extension data can be passed as part of the [GET /consumers/:uuid/export/async]({{ site.url }}/swagger/?url=candlepin/swagger-2.0.13.json#!/owners/exportDataAsync){:target="_blank"} API request by using 'ext' query parameters. The values of these parameters must follow a KEY:VALUE format.

```bash
$ curl -k -u USERNAME:PASSWORD https://localhost:8443/candlepin/consumers/CONSUMER_UUID/export/async?ext=version:1.2.3&ext=...
```

**NOTE: As of candlepin-2.0.31, the 'ext' parameters are supported in the deprecated synchronous export API, though we strongly urge the use of the asynchronous version above.**
{:.alert-bad}

In order for candlepin to load a custom implementation of this adapter, the new class will have to be created and must implement the interface and be bound in a custom guice module. These classes must then be put on candlepins classpath (usually in the form of a JAR file) post candlepin installation. Be sure to remember to restart tomcat once the classes are in place.

### An example of setting up an extension.

```Java
package org.candlepin.example;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

import org.candlepin.model.Consumer;

/**
 * A sample ExportExtensionAdapter implementation that simply creates and adds a
 * txt file to the manifest's extension directory.
 *
 */
public class SampleManifestExtensionAdapter implements ExportExtensionAdapter {

     public void extendManifest(File extensionDir, Consumer targetConsumer, Map<String, String> extensionData)
        throws IOException {
         String version = (String) extensionData.get("version");
         if (version == null) {
             throw new IOException("Missing version when adding extension data to manifest.");
         }
         File extension = new File(extensionDir, String.format("my-extension-%s.txt", version));
         PrintWriter writer = new PrintWriter(extension);
         writer.write("An extension was created for consumer " + targetConsumer.getUuid() + ".\n");
         writer.write("Version: " + version);
         writer.close();
     }

}
```

```Java
package org.candlepin.example;

import com.google.inject.AbstractModule;

/**
 * When overriding service implmentation, a custom guice module must be created. In this
 * example, we simply bind the ExportExtensionAdapter interface to our custom extension
 * adapter class so that candlepin will inject our adapter whenever the interface is
 * injected.
 *
 */
public class CustomCandlepinModule extends AbstractModule {

    @Override
    protected void configure() {
        bind(ExportExtensionAdapter.class).to(SampleManifestExtensionAdapter.class);
    }

}
```

```
# Edit /etc/candlepin/candlepin.conf
#
# In the candlepin config file, custom modules are configured with the following template:
#     module.config.$NAME_YOUR_MODULE=$FULLY_QUALIFIED_CLASS_NAME
#
# Add our custom class as follows and restart candlepin. The logs will tell you if it has
# been successfully loaded.
module.config.my_custom_candlepin_module=org.candlepin.example.CustomCandlepinModule

```

