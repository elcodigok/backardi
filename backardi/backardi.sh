#!/bin/bash 
# ------------------------------------------------------------
# Sistema de Backup: bacKardi
#
# Autor:    Maldonado Daniel Martin
#
#     <danyx@elcodigok.com.ar>
#     <danyx@larepaweb.com.ar>
#
# fecha:    08/07/2010
#
# Con este sistema es posible realizar backup tanto completos
# como asi tambien incrementales tanto de archivos como asi
# tambien de directorios.
# ------------------------------------------------------------

# ---------------- Funciones de Sistema ----------------------

which_cmd() {
  local cmd=`which $2 2>/dev/null | head -n 1`
  eval "${1}"="${cmd}"
  return 0
}

which_config() {
  local variable=`"${GREP}" -v "#" "${DIR_TRABAJO}"/bki.cnf | "${GREP}" "${2}" | "${SED}" 's/.*=//;s/^ *//' | head -n 1`
  eval "${1}"="${variable}"
  return 0
}

mensaje() {
  local mensaje="${1}"
  "${ECHO}" -e "${mensaje}"
  return 0
}

exito() {
  local mensaje="${1}"
  "${ECHO}" -e "${mensaje}\t" "\033[01;31m [ OK ] \033[00m"
  return 0
}

fracaso() {
  local mensaje="${1}"
  "${ECHO}" -e "${mensaje}\t" "\033[01;31m [ FRACASO ] \033[00m"
  return 1
}

# ----------------- Variables de Sistema ---------------------

which_cmd   GREP        grep
which_cmd   SED         sed
which_cmd   ID          id
which_cmd   ECHO        echo
which_cmd   HOSTNAME    hostname

# ---------- Obtener valores de configuracion ----------------

DIR_TRABAJO="/etc/backardi"

which_config    SISTEMA     sistema
which_config    VERSION     version
which_config    BACKUP_DIR  backup_dir
which_config    BACKUP_DEST_DIR     backup_dest_dir
which_config    COMPRESION  compresion
which_config    FORMATO     formato

#NOMBRE_FECHA=`date '+%A-%d-%B-%Y'`
NOMBRE_FECHA=`date +"${FORMATO}"`

#echo "Formato de la fecha: " `date +"${FORMATO}"`

# --------------- Control de usuario ------------------------

# La ejecucion del script solo la podra realizar el super 
# usuario root
if (( `"${ID}" -u` != 0)); then {
  mensaje   "No puede ser iniciado "${SISTEMA}" v"${VERSION}": Permiso denegado (usted debe ser root)."
  fracaso   "Verifique el usuario y luego intente nuevamente."
	exit;
} fi

# -------------- Control de aplicaciones ------------------

controlCompresor() {
	if ! ( [ -e /bin/$COMPRESION ] || [ -e /usr/bin/$COMPRESION ] ) ; then {
      mensaje   "El sistema de Compresion de archivos "${COMPRESION}" NO se encuentra disponible en su sistema."
      fracaso   "Puede utilizar otros sistemas de Compresion."
		exit;
	} fi
}

# ----- Funcion para determinar las extensiones -----------

controlExtension(){
  case "${COMPRESION}" in
    "tar")
      EXTENSION="tar"
		  COMANDO_COMPRIMIR="tar cvf"
		  COMANDO_DESCOMPRIMIR="tar xvf"
		  COMANDO_CONTENIDO="tar tvf"
		  ARGUMENTO_INCREMENTAL="-T -"
		  ARGUMENTO_DESCOMPRIMIR="-C"
		  TODOS=""
		  BANDERA=0
    ;;
    "gzip")
		  EXTENSION="tar.gz"
		  COMANDO_COMPRIMIR="tar vczf"
		  COMANDO_DESCOMPRIMIR="tar zxvf"
		  COMANDO_CONTENIDO="tar tzvf"
		  ARGUMENTO_INCREMENTAL="-T -"
		  ARGUMENTO_DESCOMPRIMIR="-C"
		  TODOS=""
		  BANDERA=0
    ;;
    "bzip2")
  		EXTENSION="tar.bz2"
	  	COMANDO_COMPRIMIR="tar -c"
		  COMANDO_DESCOMPRIMIR="tar zxvf"
      COMANDO_CONTENIDO=""
      ARGUMENTO_INCREMENTAL=""
		  ARGUMENTO_DESCOMPRIMIR="-C"
		  TODOS=""
 		  BANDERA=2
    ;;
    "rar")
  		EXTENSION="rar"
	  	COMANDO_COMPRIMIR="rar a"
		  COMANDO_DESCOMPRIMIR="rar x"
		  COMANDO_CONTENIDO="rar l"
		  ARGUMENTO_INCREMENTAL="/*"
		  ARGUMENTO_DESCOMPRIMIR="-C"
		  TODOS=""
		  BANDERA=1
		  $ECHO $COMANDO_COMPRIMIR $BACKUP_DEST_DIR/`$HOSTNAME`-$NOMBRE_FECHA-INC.$EXTENSION `find $BACKUP_DIR/* -mtime -1 -type f -print`
    ;;
    "arj")
  		EXTENSION="arj"
	  	COMANDO_COMPRIMIR="arj a"
		  COMANDO_DESCOMPRIMIR="arj x"
		  COMANDO_CONTENIDO="arj l"
		  ARGUMENTO_INCREMENTAL=""
		  ARGUMENTO_DESCOMPRIMIR="-C"
		  TODOS=""
		  BANDERA=2
    ;;
  esac
  return 0
}

# ------------------ Funcion de ayuda ---------------------

funcionAyuda(){
	"${ECHO}" >&2     "${SISTEMA}"" v""${VERSION}"
	"${ECHO}" >&2
	"${ECHO}" >&2     "Usos: backardi [comandos]"
	"${ECHO}" >&2     "      backardi --full"
	"${ECHO}" >&2     "      backardi --inc"
	"${ECHO}" >&2     "      backardi --res [archivo]"
	"${ECHO}" >&2     "      backardi --cont [archivo]"
	"${ECHO}" >&2     "      backardi --help"
	"${ECHO}" >&2
	"${ECHO}" >&2     "Comandos:"
	"${ECHO}" >&2     "Esto son alguno de los comandos o argumentos"
	"${ECHO}" >&2     "que se puede utilizar".
	"${ECHO}" >&2     " --full   -f               Realiza un Backup completo."
	"${ECHO}" >&2     " --inc    -i               Realiza un Backup incremental."
	"${ECHO}" >&2     " --res    -r  [archivo]    Restaura el archivo especificado."
	"${ECHO}" >&2     " --cont   -c  [archivo]    Muestra el contenido del archivo."
	"${ECHO}" >&2     " --help   -h               Para ver mas informacion."
	"${ECHO}" >&2
}

# ---------------- Aplicacion principal -------------------

case "$1" in 
	-f|--full)
		"${ECHO}" "--------------- Backup Full ---------------"
		controlCompresor
		controlExtension
		if [ "${BANDERA}" = 0 ] || [ "${BANDERA}" = 1 ] ; then {
			$COMANDO_COMPRIMIR $BACKUP_DEST_DIR/`$HOSTNAME`-$NOMBRE_FECHA-FULL.$EXTENSION $BACKUP_DIR$TODOS
		} else {
			$COMANDO_COMPRIMIR $BACKUP_DIR$TODOS | bzip2 > $BACKUP_DEST_DIR/`$HOSTNAME`-$NOMBRE_FECHA-FULL.$EXTENSION
		}
		fi
		"${ECHO}" "------------ Backup Finalizado ------------"
		;;
	-i|--inc)
		"${ECHO}" "--------------- Backup Inc ----------------"
		controlCompresor
		controlExtension
		if [ "${BANDERA}" = 0 ] ; then {
			find $BACKUP_DIR -mtime -1 -type f -print | $COMANDO_COMPRIMIR $BACKUP_DEST_DIR/`$HOSTNAME`-$NOMBRE_FECHA-INC.$EXTENSION $ARGUMENTO_INCREMENTAL
		}
		fi
		if [ "${BANDERA}" = 1 ] ; then {
			$COMANDO_COMPRIMIR $BACKUP_DEST_DIR/`$HOSTNAME`-$NOMBRE_FECHA-INC.$EXTENSION `find $BACKUP_DIR -mtime -1 -type f -print`
		}
		fi
		if [ "${BANDERA}" = 2 ] ; then {
			$COMANDO_COMPRIMIR `find $BACKUP_DIR$TODOS -mtime -1 -type f -print` | bzip2 > $BACKUP_DEST_DIR/`$HOSTNAME`-$NOMBRE_FECHA-INC.$EXTENSION
		} 
		fi
		"${ECHO}" "------------ Backup Finalizado ------------"
		;;
	-r|--res)
		"${ECHO}" "------------- Restaurar Backup ------------"
		controlCompresor
		controlExtension
		$COMANDO_DESCOMPRIMIR $2 $ARGUMENTO_DESCOMPRIMIR /
		"${ECHO}" "------- El sistema fue reestablecido ------"
		;;
	-c|--cont)
		controlCompresor
		controlExtension
		"${ECHO}" "---------- Contenido del archivo ----------"
		$COMANDO_CONTENIDO $2 | less
		"${ECHO}" "-------------------------------------------"
		;;
	-in|--info)
		"${ECHO}" "----------- Informacion General -----------"
		stat $2
		"${ECHO}" "-------------------------------------------"
		;;
	-V|--version)
		"${ECHO}" "${SISTEMA}"" v""${VERSION}"
		;;
	-h|--help)
		funcionAyuda
		;;
    *)
        $ECHO "Utilizar: -h o --help para mas informacion."
        ;;
    esac
exit 0
