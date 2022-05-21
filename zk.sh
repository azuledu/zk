#!/usr/bin/env bash

set -Euo pipefail

# Configuración
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
source $script_dir/zk.cfg || exit

# Colores
NOFORMAT='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'

# Punto de entrada al script.
main() {
  [[ $# -eq 0 ]] && usage
  parse_params "$@"
}

usage() {
  cat << EOF
Sintaxis: $(basename "${BASH_SOURCE[0]}") comando ['#tag']

Comandos:

tagtable      # Tabla de frecuencias de etiquetas.
tagcloud      # Nube de etiquetas.
tagnotes      # Notas asociadas a cada etiqueta.
tag '#tag1'   # Notas en las que aparezca la etiqueta #tag1
notes '#tag1' # Contenido de las notas que contengan la etiqueta #tag1

EOF
  exit
}

function get_tags() {
  grep $COMMON_GREP_OPTS -soh --exclude-dir=$EXCLUDE_DIR '#[[:alnum:]]\+[[:space:]]' $ZK_PATH
}

function get_tags_and_files() {
  # Trabajar en el directorio en el que se encuentran las notas para evitar
  # que 'grep' muestre la ruta de los archivos (notas) en los resultados.
  cd $ZK_PATH || exit
  grep $COMMON_GREP_OPTS -so --exclude-dir=$EXCLUDE_DIR '#[[:alnum:]]\+[[:space:]]' *
}

# Tabla con el número de apariciones de cada etiqueta (tabla de frecuencias). (MapReduce)
function tagtable() {
  #  map   | sort | reduce  | sort
  get_tags | sort | uniq -c | sort -rn
}

# Lista de etiquetas para generar una nube de etiquetas con apps externas.
function taglist() {
  get_tags | sort
}

# Nube de etiquetas.
function tagcloud() {
  zk taglist | wordcloud_cli --imagefile /tmp/tagcloud.png
  eog /tmp/tagcloud.png
}

# Notas asociadas a cada etiqueta en forma de tabla. (Problema: etiquetas que contengan :)
# Fase "Map" en un proceso MapReduce
function map_tagnotes() {
  get_tags_and_files | column -t -s':' -O 2,1 | sort
}

# Notas asociadas a cada etiqueta mostradas como clave:valor(es) (MapReduce)
# Fase "Reduce" en un proceso MapReduce
function tagnotes() {
  previous_tag=""
  local -A tagdictionary
  while read tag file
  do
    if [[ ($previous_tag != "$tag") ]]
    then
      key=$tag
      tagdictionary[$key]="${file:0:-3}"
    else
      files="${tagdictionary["$tag"]},${file:0:-3}"
      tagdictionary[$key]="$files"
    fi
    previous_tag=$tag
    # https://stackoverflow.com/questions/4667509/shell-variables-set-inside-while-loop-not-visible-outside-of-it
  done < <(map_tagnotes)

  # Ordenar las etiquetas alfabéticamente
  IFS=$'\n' sortedKeys=( $(sort <<<"${!tagdictionary[@]}") ) ; unset IFS

  # Mostrar diccionario tag->notas
  for key in "${sortedKeys[@]}"
  do
    echo -e "${GREEN}$key${NOFORMAT} ${tagdictionary[$key]}"
  done
}

# Notas en las que aparezca la etiqueta pasada como parámetro
function tag() {
  # Trabajar en el directorio en el que se encuentran las notas para evitar
  # que 'grep' muestre la ruta de los archivos (notas) en los resultados.
  cd $ZK_PATH || exit
  grep $COMMON_GREP_OPTS -ws --exclude-dir $EXCLUDE_DIR "$1" * ;
}

# Contenido de las notas que contengan la etiqueta pasada como parámetro
function notes() {
  # Trabajar en el directorio en el que se encuentran las notas para evitar
  # que 'grep' muestre la ruta de los archivos (notas) en los resultados.
  cd $ZK_PATH || exit
  notes="$(grep $COMMON_GREP_OPTS -wsl --exclude-dir $EXCLUDE_DIR "$1" *)"
  if [[ -n $notes ]];  then
    $NOTES_VIEWER $notes
  else
    echo -e "etiqueta ${RED}$1${NOFORMAT} no encontrada en las notas."
  fi
}

# Verifica el número de parámetros de entrada.
# $1: Num de parámetros
# $2: Num máximo de parámetros
# $3: Mensaje de error
function checkNumParam() {
  numParams=$1
  numMaxParams=$2
  errorMessage=$3
  if [ $numParams -lt $numMaxParams ]; then
    echo -e "$errorMessage"
    exit 1
  fi
}

# Comprueba si un comando está instalado en el sistema.
# $1: Comando a comprobar
function checkInstalledCommand() {
  command=$1
  if ! command -v $command &> /dev/null
  then
      echo -e "$command no encontrado"
  fi
}

# Ejecutar comando correspondiente
function parse_params() {
  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -?*) echo -e "Opción desconocida: $1" ;;
    tagtable) tagtable ; break ;;
    taglist)  taglist ; break ;;
    tagcloud) checkInstalledCommand 'wordcloud_cli' && tagcloud ; break ;;
    map_tagnotes) map_tagnotes ; break ;;
    tagnotes) tagnotes ; break ;;
    tag)
      checkNumParam $# 2 "Es necesario especificar una etiqueta: zk tag ${RED}'#tag1'" ;
      tag $2 ;
      break ;;
    notes)
      checkNumParam $# 2 "Es necesario especificar una etiqueta: zk notes ${RED}'#tag1'" ;
      notes $2 ;
      break ;;
    *) echo -e "Comando desconocido: $1" ;;
    esac
    shift
  done

  return 0
}

# Ejecutar programa principal
main "$@"
