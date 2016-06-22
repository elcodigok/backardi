#!/bin/bash
# ------------------------------------------------------------
# Sistema de Backup: bacKardi
#
# Autor:    Maldonado Daniel Martin
#
#			<daniel_5502@yahoo.com.ar>
#
# fecha:    06/07/2010
#
# Instalador del sistema
#
# ------------------------------------------------------------ 

# ------------------- Funciones de Sistema -------------------

which_cmd() {
  local cmd=`which $2 2>/dev/null | head -n 1`
  eval "${1}"="${cmd}"
  return 0
}

which_compress() {
  local cmd=`which $1 2>/dev/null | head -n 1`
  if [ $? -gt 0 -o ! -x "${cmd}" ] ; then {
	"${ECHO}" -e "[\033[01;31m X \033[00m]── "${2}""
    return 1
  } else {
    "${ECHO}" -e "[\033[01;32m O \033[00m]── "${2}"	"${cmd}""
    return 0
  }
  fi
}

mensaje() {
  local mensaje="${1}"
  "${ECHO}" -e "${mensaje}"
}

exito() {
  local mensaje="${1}"
  "${ECHO}" -e "${mensaje}\t" "\033[01;31m [ OK ] \033[00m"
}

fracaso() {
  local mensaje="${1}"
  "${ECHO}" -e "${mensaje}\t" "\033[01;31m [ FRACASO ] \033[00m"
}

titulo() {
  local mensaje="${1}"
  "${ECHO}" -e "[ "${mensaje}" ]"
}

mensaje_exito() {
  local mensaje="${1}"
  "${ECHO}" -e "[\033[01;32m OK \033[00m] ..  " "${mensaje}"
}

mensaje_fracaso() {
  local mensaje="${1}"
  "${ECHO}" -e "[\033[01;34m ! \033[00m] ... " "${mensaje}"
}

# ------------------- Variables de sistema -------------------

which_cmd   ECHO    echo
which_cmd   CP      cp
which_cmd   ID      id
which_cmd   MKDIR   mkdir
which_cmd   LN      ln
which_cmd   PWD     pwd

DIR_DESTINO="/etc/backardi/"
DIR_ENLACE="/usr/sbin"
DIR_MAN="/usr/share/man/man1"
DIR_TRABAJO=`"${PWD}"`
SISTEMA="bacKardi"
VERSION="0.7"

# --------------- Control de usuario ------------------------

# La ejecucion del script solo la podra realizar el super 
# usuario root
if (( `"${ID}" -u` != 0)); then {
  mensaje "No puede ser iniciado "${SISTEMA}" v"${VERSION}": Permiso denegado (usted debe ser root)."
  fracaso "Verifique el usuario y luego intente nuevamente."
	exit;
} fi

titulo  "INSTALACION DEL SISTEMA "${SISTEMA}" v"${VERSION}""

# ----- Crear directorio de trabajo en el sistema------------

if ( [ -e "${DIR_DESTINO}" ] ) ; then {
  mensaje_fracaso "No se puede crear el directorio "${DIR_DESTINO}" por que ya existe."
} else {
	"${MKDIR}" "${DIR_DESTINO}"
  if [ $? -eq 0 ]; then {
    mensaje_exito "Directorio "${DIR_DESTINO}.""
  }
  fi
}
fi

# ----------- Copiar archivo ejecutable ---------------------

if ( [ -e "${DIR_DESTINO}"/backardi.sh ] ) ; then {
  mensaje_fracaso "No se puede copiar el archivo en "${DIR_DESTINO}"backardi.sh por que ya existe."
} else {
	#"${CP}" backardi/backardi.sh "${DIR_DESTINO}"
  "${CP}" "${DIR_TRABAJO}"/bin/backardi.sh "${DIR_DESTINO}"
  if [ $? -eq 0 ]; then {
    mensaje_exito "Copiado "${DIR_DESTINO}"backardi.sh"
  }
  fi
}
fi

# ------- Copiar archivo de configuracion -------------------

if ( [ -e "${DIR_DESTINO}"/bki.cnf ] ) ; then {
  mensaje_fracaso "No se puede copiar el archivo en "${DIR_DESTINO}"bki.cnf por que ya existe."
} else {
	#"${CP}" backardi/bki.cnf "${DIR_DESTINO}"
  "${CP}" "${DIR_TRABAJO}"/conf/bki.cnf "${DIR_DESTINO}"
  if [ $? -eq 0 ]; then {
    mensaje_exito "Copiado "${DIR_DESTINO}"bki.cnf"
  }
  fi
}
fi

# ------------- Crear enlace simbolico ---------------------

if ( [ -e "${DIR_ENLACE}"/backardi ] ) ; then {
  mensaje_fracaso "No se puede crear el enlace simbolico en "${DIR_ENLACE}"/backardi por que ya existe."
} else {
	#$LN --symbolic $DIR_DESTINO/backardi.sh $DIR_ENLACE/backardi
  "${LN}" --symbolic "$DIR_DESTINO"/backardi.sh "${DIR_ENLACE}"/backardi
  if [ $? -eq 0 ]; then {
    mensaje_exito "Copiado "${DIR_ENLACE}"/backardi"
  }
  fi
}
fi

# ----------- Agregar paginas del manual ------------------

if ( [ -e "${DIR_MAN}"/backardi.1.gz ] ) ; then {
  mensaje_fracaso "No se puede copiar el manual en "${DIR_MAN}"/backardi.1.gz por que ya existe."
} else {
	#"${CP}" backardi/backardi.1.gz "${DIR_MAN}"
  "${CP}" "${DIR_TRABAJO}"/man/backardi.1.gz "${DIR_MAN}"
  if [ $? -eq 0 ]; then {
    mensaje_exito "Copiado "${DIR_MAN}"/backardi.1.gz"
  }
  fi
}
fi

# ---------- Comprobar algoritmos de compresion -----------

titulo "COMPROBANDO SISTEMAS DE COMPRESIÓN"

which_compress      tar     "TAR"
which_compress      gzip    "GNUZip"
which_compress      bzip2   "Bzip2"
which_compress      rar     "RAR"
which_compress      arj     "ARJ"
