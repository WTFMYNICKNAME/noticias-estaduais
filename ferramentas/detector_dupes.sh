#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# ferramentas/detector_dupes.sh — caça redundâncias no repositório,
# estilo detector de plágio:
#   1. funções com corpo idêntico (após normalização) em lugares diferentes;
#   2. funções "quase gêmeas" (similaridade por tokens ≥ 75%);
#   3. blocos de 6+ linhas normalizadas repetidos dentro/entre arquivos.
#
# Uso:
#   ./detector_dupes.sh                 examina o repositório (menos tests/)
#   ./detector_dupes.sh caminho/        examina uma pasta específica
#   ./detector_dupes.sh --tudo          inclui tests/ e fixtures
#   ./detector_dupes.sh --janela N      tamanho do bloco repetido (padrão 6)
#
# Código 1 = duplicata exata/bloco repetido (portão para CI/ritual); 0 = limpo.
# ---------------------------------------------------------------------------
set -u

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pasta="$RAIZ"
incluir_tests=0
janela=6

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tudo)    incluir_tests=1; shift;;
        --janela)  [[ $# -ge 2 ]] || { echo "--janela precisa de um número." >&2; exit 2; }
                   janela="$2"; shift 2;;
        --ajuda|-h|--help)
                   grep '^#' "$0" | cut -c3-; exit 0;;
        *)         pasta="$1"; shift;;
    esac
done
[[ -d "$pasta" ]] || { echo "Pasta não existe: $pasta" >&2; exit 2; }

# ------------------ coleção de arquivos .sh ------------------
declare -A examinar=()
while IFS= read -r -d '' arq; do
    if [[ $incluir_tests -eq 0 && "$arq" == */tests/* ]]; then continue; fi
    examinar["$arq"]=1
done < <(find "$pasta" -path "$pasta/.git" -prune -o -type f -name '*.sh' -print0 2>/dev/null | sort -z)
if [[ ${#examinar[@]} -eq 0 ]]; then
    echo "Nenhum .sh para examinar em $pasta."
    exit 0
fi

# ------------------ extração: funções e linhas ------------------
# F<037>nome<037>arquivo<037>linha<037>corpo-normalizado
# L<037>arquivo<037>linha<037>texto-normalizado
mapfile -t registros < <(
for arq in "${!examinar[@]}"; do
    awk -v arquivo="$arq" '
    function normaliza(s){ gsub(/^[ \t]+|[ \t]+$/,"",s); gsub(/[ \t]+/," ",s); return s }
    FNR==1 { inf=0 }
    {
        cru=$0; lin=normaliza($0)
        if(lin==""){ next }
        if(!inf){
            if(lin ~ /^#/){ next }
            if(lin ~ /^[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(\)[[:space:]]*\{/){
                ini=FNR
                nome=lin; sub(/\(\).*/,"",nome)
                gsub(/[ \t]/,"",nome)
                abre=index($0,"{")
                fecha=match(substr($0, abre+1), /}/)
                if(fecha){
                    corpo=normaliza(substr($0, abre+1, fecha-1))
                    print "F" "\037" nome "\037" arquivo "\037" FNR "\037" corpo
                }else{
                    inf=1; prof=1; ini_corpo=""
                }
                next
            }
            print "L" "\037" arquivo "\037" FNR "\037" lin
            next
        }
        if(inf){
            n=gsub(/{/,"",lin); m=gsub(/}/,"",lin)
            if(prof + (n-m) <= 0){
                print "F" "\037" nome "\037" arquivo "\037" ini "\037" ini_corpo
                inf=0
            }else{
                prof+=n-m
                ini_corpo=ini_corpo lin " "
            }
        }
    }' "$arq"
done
)

# ------------------ funções ------------------
declare -A corpo_hash=()
declare -A assinatura=()
parametros=0
for reg in "${registros[@]:-}"; do
    [[ -n "$reg" && "${reg:0:1}" == "F" ]] || continue
    IFS=$'\037' read -r _ nome arq ln corpo <<< "$reg"
    [[ -n "$nome" ]] || continue
    parametros=$((parametros + 1))
    h="$(printf '%s' "$corpo" | sha256sum | cut -c1-16)"
    corpo_hash["$h"]+="${nome}@${arq#"$pasta"/}:${ln}"$'\n'
    if (( $(wc -w <<< "$corpo") >= 8 )); then
        assinatura["$nome|$arq|${ln}"]="$corpo"
    fi
done

copia_exata=0
for h in "${!corpo_hash[@]}"; do
    locs="$(printf '%s' "${corpo_hash[$h]}" | grep . | sort -u)"
    if [[ "$(wc -l <<< "$locs")" -gt 1 ]]; then
        echo "🔴 DUPLICATA EXATA de função (corpos idênticos):"
        printf '%s\n' "$locs" | sed 's/^/   • /'
        copia_exata=$((copia_exata + 1))
    fi
done

declare -a seriais=()
for s in "${!assinatura[@]}"; do seriais+=("$s"); done
quase=0
for ((i=0; i<${#seriais[@]}; i++)); do
    ta="$(printf '%s\n' "${assinatura[${seriais[i]}]}" | tr ' ' '\n' | grep . | sort -u)"
    for ((j=i+1; j<${#seriais[@]}; j++)); do
        ser=$(printf '%s' "${seriais[j]}")
        tb="$(printf '%s\n' "${assinatura[$ser]}" | tr ' ' '\n' | grep . | sort -u)"
        [[ "$ta" == "$tb" ]] && continue
        comuns="$(comm -12 <(printf '%s\n' "$ta") <(printf '%s\n' "$tb") | wc -l)"
        uniao="$(( $(printf '%s\n%s\n' "$ta" "$tb" | grep . | sort -u | wc -l) ))"
        (( uniao > 0 )) || continue
        razao=$(( comuns * 100 / uniao ))
        if (( razao >= 75 )); then
            echo "🟡 GÊMEAS ~${razao}% entre ${seriais[i]%%|*} e ${ser%%|*}"
            quase=$((quase + 1))
        fi
    done
done

# ------------------ blocos de linhas repetidos ------------------
declare -A win_reg=()
declare -A arq_lin=()
declare -A arq_conteudo=()
for reg in "${registros[@]:-}"; do
    [[ -n "$reg" && "${reg:0:1}" == "L" ]] || continue
    IFS=$'\037' read -r _ arq ln texto <<< "$reg"
    arq_conteudo["$arq"]+="${texto}"$'\037'
    arq_lin["$arq"]+="${arq#"$pasta"/}:${ln}"$'\037'
done
for arq in "${!arq_conteudo[@]}"; do
    IFS=$'\037' read -r -a textos <<< "${arq_conteudo[$arq]}"
    IFS=$'\037' read -r -a posis <<< "${arq_lin[$arq]}"
    for ((k=0; k<=${#textos[@]}-janela; k++)); do
        bloco=""
        for ((m=0; m<janela; m++)); do bloco+="${textos[k+m]} "; done
        [[ ${#bloco} -ge 60 ]] || continue
        h="$(printf '%s' "$bloco" | sha256sum | cut -c1-16)"
        win_reg["$h"]+="${posis[k]}"$'\037'
    done
done
bloco_rep=0
for h in "${!win_reg[@]}"; do
    ocorr="$(printf '%s' "${win_reg[$h]}" | grep . | sort -u)"
    if [[ "$(wc -l <<< "$ocorr")" -gt 1 ]]; then
        echo "🟠 BLOCO DE $janela LINHAS REPETIDO:"
        printf '%s\n' "$ocorr" | sed 's/^/   • /'
        bloco_rep=$((bloco_rep + 1))
    fi
done

echo
echo "🔍 DETECTOR-DUPES: $parametros funções (e ${#seriais[@]} dignas de análise) em ${#examinar[@]} scripts."
echo "   $copia_exata duplicata(s) exata(s), $quase quase-gêmea(s), $bloco_rep bloco(s) repetido(s)."
[[ $copia_exata -eq 0 && $bloco_rep -eq 0 ]] || exit 1
exit 0
