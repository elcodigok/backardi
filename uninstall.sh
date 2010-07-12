#!/bin/bash
# ------------------------------------------------------------
# Sistema de Backup: bacKardi
#
# Autor:    Maldonado Daniel Martin
#
#       <danyx@elcodigok.com.ar>
#		    <danyx@larepaweb.com.ar>
#
# fecha:    07/07/2010
#
# ------------------------------------------------------------

# ----------------- Funciones de Sistema ---------------------

which_cmd() {
  local cmd=`which $2 2>/dev/null | head -n 1`
  eval "${1}"="${cmd}"
  return 0
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

# ----------------- Variables del sistema --------------------

which_cmd   ECHO    echo
which_cmd   CP      cp
which_cmd   RM      rm
which_cmd   ID      id

SISTEMA="bacKardi"
VERSION="0.6"
DIR_INSTALL="/etc/backardi"
DIR_MAN_INSTALL="/usr/share/man/man1"
DIR_LN_INSTALL="/usr/sbin"

# --------------- Control de usuario ------------------------

# La ejecucion del script solo la podra realizar el super 
# usuario root
if (( `"${ID}" -u` != 0)); then {
	mensaje "No puede ser iniciado "${SISTEMA}" v"${VERSION}": Permiso denegado (usted debe ser root)."
	fracaso "Verifique el usuario y luego intente nuevamente.";
	exit;
} fi

titulo "ELIMINACIÓN DEL SISTEMA "${SISTEMA}" v"${VERSION}""

# ------------- Eliminar enlace simbolico ---------------------

if ( [ -e $DIR_LN_INSTALL/backardi ] ) ; then {
	$RM $DIR_LN_INSTALL/backardi
  if [ $? -eq 0 ]; then {
    mensaje_exito   "Se eliminó "${DIR_LN_INSTALL}"/backardi"
  }
  fi
} else {
  mensaje_fracaso   "No se puede eliminar el enlace "${DIR_LN_INSTALL}"/backardi"
}
fi

# ----- Eliminar directorio de trabajo en el sistema------------

if ( [ -e $DIR_INSTALL ] ) ; then {
	$RM -r $DIR_INSTALL
  if [ $? -eq 0 ]; then {
    mensaje_exito   "Se eliminó "${DIR_INSTALL}""
    mensaje_exito   "Se eliminó "${DIR_INSTALL}"backardi.sh"
    mensaje_exito   "Se eliminó "${DIR_INSTALL}"bck.cnf"
  }
  fi
} else {
  mensaje_fracaso   "No se puede eliminar el directorio "${DIR_INSTALL}""
}
fi

# ----------- Eliminar paginas del manual ------------------

if ( [ -e $DIR_MAN_INSTALL/backardi.1.gz ] ) ; then {
	$RM $DIR_MAN_INSTALL/backardi.1.gz
  if [ $? -eq 0 ]; then {
    mensaje_exito   "Se eliminó "${DIR_MAN_INSTALL}"/backardi.1.gz"
  }
  fi
} else {
  mensaje_fracaso   "No se puede eliminar el Manual "${DIR_MAN_INSTALL}"/backardi.1.gz"
}
fi
