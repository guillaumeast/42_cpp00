#!/usr/bin/env bash
# Testeur pour ex00 (Megaphone) - CPP Module 00
# Verifie le Makefile, les regles interdites et la sortie du programme.

cd "$(dirname "$0")" || exit 1

NAME=$(grep -E '^[[:space:]]*NAME[[:space:]]*:?=' Makefile | head -1 | sed 's/^[^=]*=[[:space:]]*//')
SRCS=$(ls ./*.cpp ./*.hpp 2>/dev/null)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

if [ -t 1 ]; then
	R=$(printf '\033[31m'); G=$(printf '\033[32m'); Y=$(printf '\033[33m')
	B=$(printf '\033[1m'); N=$(printf '\033[0m')
else
	R=; G=; Y=; B=; N=
fi

ok=0
ko=0

pass() { ok=$((ok + 1)); printf '  %s[OK]%s   %s\n' "$G" "$N" "$1"; }
fail() {
	ko=$((ko + 1)); printf '  %s[KO]%s   %s\n' "$R" "$N" "$1"
	[ -n "$2" ] && printf '%s\n' "$2" | sed 's/^/         /'
}
title() { printf '\n%s== %s ==%s\n' "$B" "$1" "$N"; }

mtime() { stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null; }

# ---------------------------------------------------------------- compilation

title "Compilation"

make fclean >/dev/null 2>&1
if make >"$TMP/build" 2>&1; then
	pass "make compile sans erreur"
else
	fail "make echoue" "$(cat "$TMP/build")"
	printf '\n%sBuild impossible, arret.%s\n' "$R" "$N"
	exit 1
fi

if [ -x "$NAME" ]; then
	pass "l'executable ./$NAME est cree"
else
	fail "pas d'executable nomme '$NAME'"
	exit 1
fi

if grep -q -- "-Wall" "$TMP/build" && grep -q -- "-Wextra" "$TMP/build" &&
	grep -q -- "-Werror" "$TMP/build"; then
	pass "compile avec -Wall -Wextra -Werror"
else
	fail "flags -Wall -Wextra -Werror absents de la ligne de compilation"
fi

if grep -q -- "-std=c++98" "$TMP/build"; then
	pass "compile avec -std=c++98"
else
	fail "flag -std=c++98 absent"
fi

if grep -qE '(^|[[:space:]/])(c\+\+|clang\+\+|g\+\+)[[:space:]]' "$TMP/build"; then
	pass "utilise le compilateur c++"
else
	fail "le compilateur appele ne semble pas etre c++"
fi

# warnings meme non fatals
if grep -qiE 'warning:' "$TMP/build"; then
	fail "des warnings sont emis" "$(grep -iE 'warning:' "$TMP/build")"
else
	pass "aucun warning a la compilation"
fi

# C++98 strict : detecte les features C++11 que -std=c++98 laisse passer
if c++ -Wall -Wextra -Werror -std=c++98 -pedantic-errors -c megaphone.cpp \
	-o "$TMP/pedantic.o" >"$TMP/pedantic" 2>&1; then
	pass "compile en C++98 strict (-pedantic-errors)"
else
	fail "echoue en C++98 strict : feature C++11 ?" "$(cat "$TMP/pedantic")"
fi

# ------------------------------------------------------------------- Makefile

title "Makefile"

before=$(mtime "$NAME")
make >"$TMP/relink" 2>&1
after=$(mtime "$NAME")
if [ "$before" = "$after" ] && ! grep -qE -- "-o $NAME|-c " "$TMP/relink"; then
	pass "pas de relink quand rien n'a change"
else
	fail "le Makefile relink" "$(cat "$TMP/relink")"
fi

hpp=$(ls ./*.hpp 2>/dev/null | head -1)
if [ -n "$hpp" ]; then
	hdr=$(basename "$hpp")
	deps=$(find . -name '*.d' 2>/dev/null)
	if [ -n "$deps" ] && grep -qF "$hdr" $deps; then
		pass "les fichiers .d listent bien $hdr"
	else
		fail "aucun .d ne mentionne $hdr (-MMD manquant ?)"
	fi
	# make 3.81 compare les mtimes a la seconde : le header doit etre
	# strictement plus recent que le .o, d'ou le sleep.
	sleep 1
	touch "$hpp"
	if make -n 2>/dev/null | grep -q -- ' -c '; then
		pass "modifier un .hpp declenche une recompilation"
	else
		fail "modifier $hdr ne recompile rien (deps manquantes)"
	fi
else
	printf '  %s[--]%s   pas de .hpp ici, test des deps non applicable\n' "$Y" "$N"
fi

for rule in all clean fclean re; do
	if make -n "$rule" >/dev/null 2>&1; then
		pass "regle '$rule' presente"
	else
		fail "regle '$rule' manquante"
	fi
done

make fclean >/dev/null 2>&1
if [ ! -e "$NAME" ] && [ -z "$(ls ./*.o 2>/dev/null)" ]; then
	pass "fclean supprime l'executable et les .o"
else
	fail "fclean laisse des fichiers derriere lui"
fi
make >/dev/null 2>&1

# ------------------------------------------------------------------ interdits

title "Elements interdits"

check_forbidden() {
	found=$(grep -nE "$1" $SRCS 2>/dev/null)
	if [ -z "$found" ]; then
		pass "pas de $2"
	else
		fail "$2 detecte" "$found"
	fi
}

check_forbidden '\b(printf|sprintf|fprintf|snprintf|vprintf)[[:space:]]*\(' "fonction *printf()"
check_forbidden '\b(malloc|calloc|realloc|free)[[:space:]]*\(' "malloc/calloc/realloc/free"
check_forbidden '\busing[[:space:]]+namespace\b' "'using namespace'"
check_forbidden '\bfriend\b' "mot-cle 'friend'"
check_forbidden '#[[:space:]]*include[[:space:]]*<(vector|list|map|set|deque|queue|stack|algorithm)>' \
	"conteneur/algorithme STL"

# fonctions C++ interdites aux modules 00-07 via <algorithm>, et new sans delete
news=$(grep -cE '\bnew\b' $SRCS 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')
dels=$(grep -cE '\bdelete\b' $SRCS 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')
if [ "$news" -eq 0 ]; then
	pass "aucune allocation dynamique (rien a liberer)"
elif [ "$dels" -gt 0 ]; then
	pass "new present, delete present ($news new / $dels delete) - a verifier a la main"
else
	fail "$news 'new' sans aucun 'delete' : fuite memoire"
fi

for f in $SRCS; do
	case "$f" in
	*.hpp)
		if grep -q '#[[:space:]]*ifndef\|#[[:space:]]*pragma once' "$f"; then
			pass "$f a un include guard"
		else
			fail "$f n'a pas d'include guard"
		fi
		;;
	esac
done

# ------------------------------------------------------------------- execution

title "Sortie du programme"

run_case() {
	desc="$1"; expected="$2"; shift 2
	./"$NAME" "$@" >"$TMP/out" 2>"$TMP/err"
	code=$?
	printf '%s\n' "$expected" >"$TMP/exp"
	if ! cmp -s "$TMP/out" "$TMP/exp"; then
		fail "$desc" "attendu : $(cat -e "$TMP/exp")
obtenu  : $(cat -e "$TMP/out")
"
		return
	fi
	if [ -s "$TMP/err" ]; then
		fail "$desc (ecrit sur stderr)" "$(cat "$TMP/err")"
		return
	fi
	if [ "$code" -ne 0 ]; then
		fail "$desc (code de retour $code au lieu de 0)"
		return
	fi
	pass "$desc"
}

# les trois exemples du sujet, au caractere pres
run_case "exemple 1 du sujet" \
	"SHHHHH... I THINK THE STUDENTS ARE ASLEEP..." \
	"shhhhh... I think the students are asleep..."

run_case "exemple 2 du sujet (args concatenes)" \
	"DAMNIT ! SORRY STUDENTS, I THOUGHT THIS THING WAS OFF." \
	"Damnit" " ! " "Sorry students, I thought this thing was off."

run_case "exemple 3 du sujet (sans argument)" \
	"* LOUD AND UNBEARABLE FEEDBACK NOISE *"

# cas limites
run_case "deja en majuscules" "HELLO" "HELLO"
run_case "chiffres et symboles inchanges" "42 !? #\$%" "42 !? #\$%"
run_case "argument vide -> ligne vide" ""  ""
run_case "plusieurs arguments vides" "" "" "" ""
run_case "concatenation sans separateur" "ABC" "a" "b" "c"
run_case "espaces internes preserves" "A  B" "a  B"
run_case "espaces de fin preserves" "HI  " "hi  "
run_case "tabulation preservee" "$(printf 'A\tB')" "$(printf 'a\tb')"
run_case "un seul caractere" "X" "x"
run_case "melange de casse" "MIXED" "MiXeD"
run_case "octets non ASCII (UTF-8) inchanges" \
	"$(printf 'ETE \303\251T\303\251')" "$(printf 'ete \303\251t\303\251')"

# pas de crash sur un argument tres long
long=$(head -c 100000 /dev/zero | tr '\0' 'a')
./"$NAME" "$long" >"$TMP/out" 2>&1
if [ "$(wc -c <"$TMP/out")" -eq 100001 ] && ! grep -q '[a-z]' "$TMP/out"; then
	pass "argument de 100000 caracteres"
else
	fail "argument de 100000 caracteres"
fi

# ---------------------------------------------------------------------- resume

printf '\n%s== Resume ==%s\n' "$B" "$N"
printf '  %s%d reussis%s, %s%d echoues%s\n\n' "$G" "$ok" "$N" "$R" "$ko" "$N"

[ "$ko" -eq 0 ] || exit 1
