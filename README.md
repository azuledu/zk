# Zettelkasten

Utilidades y notas relacionadas con Zettelkasten digital.

En `docs/ZK-hashtags.pdf` se describen las motivaciones de las que surgen los scripts.

En `integraciones` se encuentran plugins para diferentes aplicaciones que extienden Markdown añadiendo resaltado de sintaxis para hashtags.

El directorio `bash` contiene un script para gestionar notas enlazadas mediante hashtags.


### Instalación herramientas adicionales

#### Bat

Bat permite **resaltado de sintaxis** en el terminal.

Instalar Bat desde https://github.com/sharkdp/bat

Modificar la variable `NOTES_VIEWER` en el archivo `/usr/local/bin/zk.cfg`


#### WordCloud

[_WordCloud_](https://github.com/amueller/word_cloud) permite generar de nubes de palabras a partir de textos.

Para generar una **nube de etiquetas** directamente mediante `zk tagcloud` debemos instalarlo:

``` bash
sudo apt install python3-wordcloud
```


## Integraciones

#### Bat

Añade resaltado de sintaxis para hashtags como si fueran enlaces.

``` bash
mkdir -p "$(bat --config-dir)/syntaxes"
cd "$(bat --config-dir)/syntaxes"
ln -s ~/git/zk/integraciones/bat/Markdown.sublime-syntax "$(bat --config-dir)/syntaxes/Markdown.sublime-syntax"
bat cache --build
```

Después de las actualizaciones de Bat es necesario ejecutar `bat cache --build` de nuevo.



#### Sublime Text

Utiliza el mismo sistema que Bat para definir el resaltado de sintaxis por lo que puede usarse el mismo fichero.



#### Atom

https://atom.io/packages/language-markdown-hashtags

Syntax highlighting for hashtags in Markdown.

```bash
apm install language-markdown-hashtags

```


#### Pulsar

- El plugin para Atom también sirve para Pulsar (https://web.pulsar-edit.dev/packages/language-markdown-hashtags).

```bash
ppm install language-markdown-hashtags

```


## Script zk

**Instalación**:

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

**Utilización**:

``` bash
Sintaxis: zk comando ['#tag']

Comandos:

tagtable      # Tabla de frecuencias de etiquetas.
tagcloud      # Nube de etiquetas.
tagnotes      # Notas asociadas a cada etiqueta.
tag '#tag1'   # Notas en las que aparezca la etiqueta #tag1
notes '#tag1' # Contenido de las notas que contengan la etiqueta #tag1
```

Si está instalado **Bat** se mejora la visualización del contenido de las notas mediante `zk notes '#tag1'`


**Nube de etiquetas**

Es posible generar una tabla con el número de apariciones de cada etiqueta mediante `zk tagtable`. Esta **tabla de frecuencias** se puede considerar una visualización alternativa de una nube de etiquetas.

El comando `zk taglist` genera una lista con todas las etiquetas. Esta lista puede usarse como entrada para aplicaciones de generación de nubes de palabras a partir de textos. Una aplicación usada habitualmente es [_WordCloud_](https://github.com/amueller/word_cloud)

Si lo tenemos instalado es posible generar una nube de etiquetas directamente mediante `zk tagcloud`
