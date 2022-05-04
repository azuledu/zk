#!/usr/bin/env bash
#set -x
set -Eeuo pipefail

# Configuración
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
source $script_dir/zk.cfg

main() {
  setup_colors
  [[ $# -eq 0 ]] && usage
  parse_params "$@"
}

usage() {
  cat << EOF # remove the space between << and EOF, this is due to web plugin issue
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

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

# Tabla con el número de apariciones de cada etiqueta (tabla de frecuencias).
function tagtable() {
  grep $COMMON_GREP_OPTS -oh '#[[:alnum:]]\+[[:space:]]' $ZK_PATH \
  | sort | uniq -c | sort -rn
}

# Lista de etiquetas para generar una nube de etiquetas con apps externas.
function taglist() {
  grep $COMMON_GREP_OPTS -soh --exclude-dir=$EXCLUDE_DIR '#[[:alnum:]]\+[[:space:]]' * | sort
}

# Nube de etiquetas.
function tagcloud() {
  zk taglist | wordcloud_cli --imagefile /tmp/tagcloud.png
  eog /tmp/tagcloud.png
}

# Notas asociadas a cada etiqueta en forma de tabla. (Problema: etiquetas que contengan :)
function simple_tagnotes() {
  grep $COMMON_GREP_OPTS -so --exclude-dir=$EXCLUDE_DIR '#[[:alnum:]]\+[[:space:]]' * \
  | column -t -s':' -O 2,1 | sort | uniq
}

# Notas asociadas a cada etiqueta mostradas como clave:valor(es)
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
  done < <(simple_tagnotes)

  # Ordenar las etiquetas alfabéticamente
  IFS=$'\n' sortedKeys=( $(sort <<<"${!tagdictionary[@]}") ) ; unset IFS

  for key in "${sortedKeys[@]}"
  do
    msg "${RED}$key${NOFORMAT} ${tagdictionary[$key]}"
  done
}

# Notas en las que aparezca la etiqueta pasada como parámetro
function tag() {
  grep $COMMON_GREP_OPTS -ws --exclude-dir $EXCLUDE_DIR "$1" * ;
}

# Contenido de las notas que contengan la etiqueta pasada como parámetro
function notes() {
    $NOTES_VIEWER $(grep $COMMON_GREP_OPTS -wsl --exclude-dir $EXCLUDE_DIR "$1" $ZK_PATH);
}

# $1: Num de parámetros
# $2: Num máximo de parámetros
# $3: Mensaje de error
function checkNumParam() {
  numParams=$1
  numMaxParams=$2
  errorMessage=$3
  if [ $numParams -lt $numMaxParams ]; then
    msg "$errorMessage"
    exit 1
  fi
}

function parse_params() {
  dir=`pwd -P`
  cd $ZK_PATH
  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -?*) die "Opción desconocida: $1" ;;
    tagtable) tagtable ; break ;;
    taglist) taglist ; break ;;
    tagcloud) tagcloud ; break ;;
    simple_tagnotes) simple_tagnotes ; break ;;
    tagnotes) tagnotes ; break ;;
    tag)
      checkNumParam $# 2 "Es necesario especificar una etiqueta: zk tag ${RED}'#tag1'" ;
      tag $2 ;
      break ;;
    notes)
      checkNumParam $# 2 "Es necesario especificar una etiqueta: zk notes ${RED}'#tag1'" ;
      notes $2 ;
      break ;;
    *) die "Comando desconocido: $1" ;;
    esac
    shift
  done
  cd $dir

  return 0
}


main "$@"
