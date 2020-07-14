#!/bin/bash

on=".*"
ol="x"
od="$(date -d "2020-01-01 00:00:00 UTC" +%s)" #se não se ativar a opção -d, queremos que todos os ficheiros sejam considerados, o que é equivalente a executar tudo com uma data no futuro
oL="x"
oa="0"
or="0"
while getopts :n:l:d:L:ar opt
do
    case "$opt" in
        n) #echo "Opção -n, valor $OPTARG"
		on="$OPTARG"
            ;;
        l) #echo "Opção -l, valor $OPTARG"
            if [[ "$oL" -ne "x" ]]; then
                echo "Não pode usar -l e -L ao mesmo tempo"
                exit 1
            fi
            if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
                ol="$OPTARG"
            else
                echo "Opção -l "$OPTARG" não é um número"
		        exit 1
            fi
            ;;
        d) #echo "Opção -d, valor $OPTARG"
            test="$(date -d "$OPTARG" +%s &> /dev/null)"
            if [[ $? -eq 0 ]]
            then
                od="$(date -d "$OPTARG" +%s)"
            else
                echo "Opção -d "$OPTARG" não é uma data"
            	exit 1
	    fi
            ;;
        L) #echo "Opção -L, valor $OPTARG"
            if [[ "$ol" -ne "x" ]]; then
                echo "Não pode usar -l e -L ao mesmo tempo"
                exit 1
            fi
            if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
                oL="$OPTARG"
            else
                echo "Opção -L "$OPTARG" não é um número"
		        exit 1
            fi
            ;;
        a) #echo "Opção -a"
            oa=1
            ;;
        r) #echo "Opção -r"
            or=1
            ;;
        *) echo "Opção inválida: $opt"
	       exit 1
	    ;;
    esac
done

shift $(( $OPTIND - 1 ))

count=1
. libspace.sh

if [[ "$or" -eq "1" && "$oa" -eq "0" ]]; then
{
for dir in "$@"
do
    if ! [[ -d "$dir" ]]; then
        echo "$dir" não é uma directoria
        exit 1
    fi

    test="$(ls "$dir" &> /dev/null)"
    if [[ $? -ne 0 ]]; then
        echo "NA $dir"
    else
        if [[ "$oL" -eq "x" ]]; then
            size="0"
            find_dir "$dir" "$ol" "$od" "$on"
        else
            find_file "$dir" "$oL" "$od" "$on"
        fi
    fi
    count=$(( $count + 1 ))
done;
} | sort -n

elif [[ "$or" -eq "0" && "$oa" -eq "0" ]]; then
{
for dir in "$@"
do
    if ! [[ -d "$dir" ]]; then
        echo "$dir" não é uma directoria
        exit 1
    fi

    test="$(ls "$dir" &> /dev/null)"
    if [[ $? -ne 0 ]]; then
        echo "NA $dir"
    else
        if [[ "$oL" -eq "x" ]]; then
            size="0"
            find_dir "$dir" "$ol" "$od" "$on"
        else
            find_file "$dir" "$oL" "$od" "$on"
        fi
    fi
    count=$(( $count + 1 ))
done;
} | sort -k1nr

elif [[ "$or" -eq "0" && "$oa" -eq "1" ]]; then
{
for dir in "$@"
do
    if ! [[ -d "$dir" ]]; then
        echo "$dir" não é uma directoria
        exit 1
    fi

    test="$(ls "$dir" &> /dev/null)"
    if [[ $? -ne 0 ]]; then
        echo "NA $dir"
    else
        if [[ "$oL" -eq "x" ]]; then
            size="0"
            find_dir "$dir" "$ol" "$od" "$on"
        else
            find_file "$dir" "$oL" "$od" "$on"
        fi
fi
    count=$(( $count + 1 ))
done;
} | sort -k2
else
{
for dir in "$@"
do
    if ! [[ -d "$dir" ]]; then
        echo "$dir" não é uma directoria
        exit 1
    fi

    test="$(ls "$dir" &> /dev/null)"
    if [[ $? -ne 0 ]]; then
        echo "NA $dir"
    else
        if [[ "$oL" -eq "x" ]]; then
            size="0"
            find_dir "$dir" "$ol" "$od" "$on"
        else
            find_file "$dir" "$oL" "$od" "$on"
        fi
fi
    count=$(( $count + 1 ))
done;
} | sort -k2r

fi
