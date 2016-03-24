---
title: Diagramming with PlantUml
---

# Diagramming with PlantUML
The candlepin project Jekyll site has embedded PlantUML so that  you can add diagrams
to your documentation easily.

PlantUML can be used to create many different types of diagrams. Check out <http://plantuml.com/>
for details.

For example, a basic sequence diagram of Alice saying hello to Bob.

```
{% raw %}{% plantuml %}
Bob->Alice : hello
{% endplantuml %}{% endraw %}
```

Becomes:

{% plantuml %}
Bob->Alice : hello
{% endplantuml %}


