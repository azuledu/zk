# Zettelkasten

Utilidades y notas relacionadas con Zettelkasten digital.

En docs/ZK-hashtags.pdf se describen las motivaciones de las que surge el script `zk.sh`


### Script zk

``` bash
Sintaxis: zk comando ['#tag']

Comandos:

tagtable      # Tabla de frecuencias de etiquetas.
tagcloud      # Nube de etiquetas.
tagnotes      # Notas asociadas a cada etiqueta.
tag '#tag1'   # Notas en las que aparezca la etiqueta #tag1
notes '#tag1' # Contenido de las notas que contengan la etiqueta #tag1
```

##### Instalación

``` bash
mkdir ~/git/zk
git clone https://github.com/azuledu/zk.git
sudo ln -s ~/git/zk/zk.sh /usr/local/bin/zk
sudo ln -s ~/git/zk/zk.cfg /usr/local/bin/zk.cfg
```


### Nube de etiquetas

Es posible generar una tabla con el número de apariciones de cada etiqueta mediante `zk tagtable`. Esta **tabla de frecuencias** se puede considerar una visualización alternativa de una nube de etiquetas.

El comando `zk taglist` genera una lista con todas las etiquetas. Esta lista puede usarse como entrada para aplicaciones de generación de nubes de palabras a partir de textos. Una aplicación usada habitualmente es [WordCloud | https://github.com/amueller/word_cloud ]

Para instalar _WordCloud_:

``` bash
sudo apt install python3-wordcloud
```

Una vez instalado se puede generar una nube de etiquetas directamente mediante `zk tagcloud`
