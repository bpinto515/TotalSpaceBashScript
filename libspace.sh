#!/bin/bash

#---------------------------------------------------------------------------------#
#|                            função para a opção -l                             |#
#---------------------------------------------------------------------------------#

find_dir()
{
    # Alocação de variáveis locais
    local Ndir="$(ls -l "$1" | grep -c ^d )" # N.º de subdiretórios. Assume-se que $1 tem sempre as permissões necessárias para que este comando execute, ou seja, à partida é possível fazer ls no diretório $1

    local Nfile="$(ls "$1" -ltu --time-style=+%s | sort -k6 | grep ^"$4"$ | awk -v adate="$3" '{if($6<adate) print;}'| grep -c ^-)" # N.º de ficheiros

    local dir_size # Tamanho do diretório, de acordo com as condições (n.º de bytes)

    # Se o diretório não tiver ficheiros, o n.º de bytes associado ao diretório é 0, se tiver, sacar a soma dos bytes dos l maiores ficheiros
    if [[ "$Nfile" -eq "0" ]]; then
        dir_size="0"
    else
        
	# Verificar se o $2, que corresponde a -l, tem parametro numérico, basicamente permite ao programa correr o default de quando nem -l, nem -L são chamados
        local l_select
        if [[ "$2" -eq "x" ]]; then
            l_select="$Nfile"
        else
            l_select="$2"
        fi
        dir_size="$(ls "$1" -ltu --time-style=+%s | sort -k6 | grep ^"$4"$ | awk -v adate="$3" '{if($6<adate) print;}'| grep ^- | awk '{print '\$5'}' | sort -n | tail -"$l_select" | paste -sd+ | bc)"
    fi

    local rel_dir="$1" #="$(realpath "$1")"

# ---------------------------------------------------------------------------------------------------

    # Dois casos:
    # Se não há mais subdiretórios, a variável global "size" fica com o valor do tamanho do diretório
    # Se há mais subdiretórios, a função é chamada de novo para cada um deles
    if [[ "$Ndir" -eq "0" ]]; then
        size="$dir_size"

    else

        local dir_list=$(ls -l "$1" | grep ^d | awk '{for(i=10;i<=NF;i++) $9=$9 OFS $i; print $9}') # lista dos subdiretórios, a linha de código em awk permite salvaguardar os casos em que o nome dos diretórios têm espaços

	# Para não ter problemas quando os nomes dos diretórios têm espaços
        old_ifs="$IFS"
        IFS=$'\n'
        local dir_array=( $dir_list )
        IFS="$old_ifs"

	# Percorre todos os subdiretórios do diretório atual
        for i in $( seq 0 $(( ${#dir_array[@]} - 1 )) )
        do
	    # Se o diretório tem permissões para fazer ls, chama a função, se não, o seu dir_size é NA
            test="$(ls "$rel_dir/${dir_array[$i]}" &> /dev/null)"
            if [[ $? -eq 0 ]]; then
                find_dir "$rel_dir/${dir_array[$i]}" "$2" "$3" "$4"

                # Se algum diretório-filho não tiver permissões para fazer ls, então todos os diretórios pai acima desses ficam com NA
                if [[ "$size" == "NA" || "$dir_size" == "NA" ]]; then
                    dir_size="NA"
                else
                    dir_size=$(( $dir_size + $size ))
                fi
            else
                dir_size="NA"
                echo ""$dir_size" "$rel_dir/${dir_array[$i]}""
                size="$dir_size"
            fi
        done
    fi
    size="$dir_size"
    echo ""$dir_size" "$rel_dir""
    return 0
}

####################################################################################

#---------------------------------------------------------------------------------#
#|                            função para a opção -L                             |#
#---------------------------------------------------------------------------------#


find_file ()
{
    # Alocação de variáveis locais
    local Ndir="$(ls -l "$1" | grep -c ^d)" # N.º de subdiretórios
    local Nfile="$(ls "$1" -ltu --time-style=+%s | sort -k6 | tail -n +2 | grep ^"$4"$ | awk -v adate="$3" '{if($6<adate) print;}'| grep -c ^-)" # N.º de ficheiros
    
    local l_select="$2"
   
    local rel_dir="$1"

    # Seleciona os l_select maiores ficheiros no diretório e imprime o seu tamanho e o seu caminho    
    ls "$1" -ltu --time-style=+%s | sort -k6 | tail -n +2 | grep ^"$4"$ | grep ^- | awk -v adate="$3" '{if($6<adate) print;}' | awk -v var="$rel_dir" '{for(i=8;i<=NF;i++) $7=$7 OFS $i; print $5 " "var"/"$7}' | sort -k1n | tail -"$l_select"


# -----------------------------------------------------------------------------

    # Dois casos:
    # Se não há mais subdiretórios, a função termina
    # Se há mais subdiretórios, a função é chamada de novo para cada um deles
    if [[ "$Ndir" -eq "0" ]]; then
        return 0

    else

        local dir_list=$(ls -l "$1" | grep ^d | awk '{for(i=10;i<=NF;i++) $9=$9 OFS $i; print $9}') # lista dos subdiretórios

        old_ifs="$IFS"
        IFS=$'\n'
        local dir_array=( $dir_list )
        IFS="$old_ifs"


        for i in $( seq 0 $(( ${#dir_array[@]} - 1 )) )
        do
            # Se o diretório tem permissões para fazer ls, chama a função
            #ls "$rel_dir/${dir_array[$i]}"
            test="$(ls "$rel_dir/${dir_array[$i]}" &> /dev/null)"
            if [[ $? -eq 0 ]]; then
                find_file "$rel_dir/${dir_array[$i]}" "$2" "$3" "$4"
            fi
            done
    fi
}

