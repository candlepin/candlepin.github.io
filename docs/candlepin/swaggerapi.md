---
title: REST API
---
# Swagger API
Candlepin exposes Swagger file as a documentation of the service. When using deployed candlepin the swagger file can be accessed at:

```
https://HOST:8443/candlepin/swagger.json

```
An interactive user interface that allows running Candlepin methods can be accessed at:

```
https://HOST:8443/candlepin/docs/
```

If you do not want to serve Swagger, you can turn it off with the following configuration property:

```
candlepin.swagger.enabled=false
```

We also host the Swagger file and the UI statically on this site: 

| Version | Swagger file | Interactive documentation |
|-
| 2.1.25 |  [swagger.json]({{ site.url }}/swagger/candlepin/swagger-2.1.25.json){:target="_blank"}  | [Swagger UI]({{ site.url }}/swagger/?url=candlepin/swagger-2.1.25.json){:target="_blank"} |
| 2.3.10 |  [swagger.json]({{ site.url }}/swagger/candlepin/swagger-2.3.10.json){:target="_blank"}  | [Swagger UI]({{ site.url }}/swagger/?url=candlepin/swagger-2.3.10.json){:target="_blank"} |
| 2.4.8 |  [swagger.json]({{ site.url }}/swagger/candlepin/swagger-2.4.8.json){:target="_blank"}  | [Swagger UI]({{ site.url }}/swagger/?url=candlepin/swagger-2.4.8.json){:target="_blank"} |
| 2.5.7 |  [swagger.json]({{ site.url }}/swagger/candlepin/swagger-2.5.7.json){:target="_blank"}  | [Swagger UI]({{ site.url }}/swagger/?url=candlepin/swagger-2.5.7.json){:target="_blank"} |
| 2.9.17 |  [swagger.json]({{ site.url }}/swagger/candlepin/swagger-2.9.17.json){:target="_blank"}  | [Swagger UI]({{ site.url }}/swagger/?url=candlepin/swagger-2.9.17.json){:target="_blank"} |
| 3.1.16 |  [swagger.json]({{ site.url }}/swagger/candlepin/swagger-3.1.16.json){:target="_blank"}  | [Swagger UI]({{ site.url }}/swagger/?url=candlepin/swagger-3.1.16.json){:target="_blank"} |
| 4.0.18 |  [swagger.json]({{ site.url }}/swagger/candlepin/swagger-4.0.18.json){:target="_blank"}  | [Swagger UI]({{ site.url }}/swagger/?url=candlepin/swagger-4.0.18.json){:target="_blank"} |
| 4.1.13 | [swagger.json](https://raw.githubusercontent.com/candlepin/candlepin/candlepin-4.1-HOTFIX/api/candlepin-api-spec.yaml){:target="_blank"} | [Swagger UI](https://petstore.swagger.io/?url=https://raw.githubusercontent.com/candlepin/candlepin/candlepin-4.1-HOTFIX/api/candlepin-api-spec.yaml){:target="_blank"} |
| 4.2.17-1 | [openapi.yaml](https://raw.githubusercontent.com/candlepin/candlepin/candlepin-4.2-HOTFIX/api/candlepin-api-spec.yaml){:target="_blank"} | [Swagger UI](https://petstore.swagger.io/?url=https://raw.githubusercontent.com/candlepin/candlepin/candlepin-4.2-HOTFIX/api/candlepin-api-spec.yaml){:target="_blank"} |
| 4.3.10-1 | [openapi.yaml](https://raw.githubusercontent.com/candlepin/candlepin/candlepin-4.3-HOTFIX/api/candlepin-api-spec.yaml){:target="_blank"} | [Swagger UI](https://petstore.swagger.io/?url=https://raw.githubusercontent.com/candlepin/candlepin/candlepin-4.3-HOTFIX/api/candlepin-api-spec.yaml){:target="_blank"} |
| 4.3.9-1 | [openapi.yaml](https://raw.githubusercontent.com/candlepin/candlepin/main/api/candlepin-api-spec.yaml){:target="_blank"} | [Swagger UI](https://petstore.swagger.io/?url=https://raw.githubusercontent.com/candlepin/candlepin/main/api/candlepin-api-spec.yaml){:target="_blank"} |
|=
