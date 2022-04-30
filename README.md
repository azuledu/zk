# Zettelkasten

Utilidades y notas relacionadas con Zettelkasten digital.

En doc/ZK-hashtags.pdf se describen las motivaciones de las que surge el script zk.


### Script zk

```
Sintaxis: zk comando ['#tag']

Comandos:

tags          # Mostrar las notas asociadas a cada etiqueta
tagscloud     # Número de veces que aparece cada una de las etiquetas (nube de etiquetas)
tag '#tag1'   # Buscar las notas en las que aparezca la etiqueta #tag1
notes '#tag1' # Mostrar el contenido de las notas que contengan la etiqueta #tag1
```

##### Instalación

```bash
sudo ln -s ~/git/zk/zk.sh /usr/local/bin/zk
sudo ln -s ~/git/zk/zk.cfg /usr/local/bin/zk.cfg
```
