# Zettelkasten

Utilidades y notas relacionadas con Zettelkasten digital.

En docs/ZK-hashtags.pdf se describen las motivaciones de las que surge el script `zk.sh`


### Instalación

##### Script zk

``` bash
mkdir ~/git/zk
git clone https://github.com/azuledu/zk.git
sudo ln -s ~/git/zk/zk.sh /usr/local/bin/zk
sudo cp ~/git/zk/zk.cfg /usr/local/bin/zk.cfg
```

Configurar las opciones deseadas en el archivo `/usr/local/bin/zk.cfg`

Para tener **autocompletado** en el script:

``` bash
sudo ln -s ~/git/zk/zk-bash-completion /etc/bash_completion.d/zk
```


##### Bat

Bat permite **resaltado de sintaxis** en el terminal.

Instalar Bat desde https://github.com/sharkdp/bat

Modificar la variable `NOTES_VIEWER` en el archivo `/usr/local/bin/zk.cfg`


##### WordCloud

[_WordCloud_](https://github.com/amueller/word_cloud) permite generar de nubes de palabras a partir de textos.

Para generar una **nube de etiquetas** directamente mediante `zk tagcloud` debemos instalarlo:

``` bash
sudo apt install python3-wordcloud
```


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

### Nube de etiquetas

Es posible generar una tabla con el número de apariciones de cada etiqueta mediante `zk tagtable`. Esta **tabla de frecuencias** se puede considerar una visualización alternativa de una nube de etiquetas.

El comando `zk taglist` genera una lista con todas las etiquetas. Esta lista puede usarse como entrada para aplicaciones de generación de nubes de palabras a partir de textos. Una aplicación usada habitualmente es [_WordCloud_](https://github.com/amueller/word_cloud)

Si lo tenemos instalado es posible generar una nube de etiquetas directamente mediante `zk tagcloud`


### Integraciones

##### Bat

Añade resaltado de sintaxis para hashtags como si fueran enlaces. Facilita la visualización del contenido de las notas mediante `zk notes '#tag1'`

``` bash
mkdir -p "$(bat --config-dir)/syntaxes"
cd "$(bat --config-dir)/syntaxes"
ln -s ~/git/zk/integraciones/bat/Markdown.sublime-syntax "$(bat --config-dir)/syntaxes/Markdown.sublime-syntax"
bat cache --build
```
