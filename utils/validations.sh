#!/bin/bash

function valida_argumento() {
    if [ $# -eq 0 ]
    then
	    echo
	    echo "Favor informar um ambiente como argumento."
	    echo $0" < DEV | HML | ACT | PRD | FIX | MGR | MGRNONPRD | SGI | ROOT >"
	    echo
	    exit 1
    else
        case $(echo $AMBIENTE) in
            DEV) : ;;
            HML) : ;;
            ACT) : ;;
            PRD) : ;;
            FIX) : ;;
            MGR) : ;;
            MGRNONPRD) : ;;
            SGI) : ;;
            ROOT) : ;;
	        *)
                echo "$AMBIENTE está fora do padrão, ajuste para um ambiente válido"
                echo "< DEV | HML | ACT | PRD | FIX | MGR | MGRNONPRD | SGI | ROOT >"
                exit 1
        esac
    fi
}

function valida_ambiente() {
    if [[ $(find ./tfvars -type f) != *"$AMBIENTE"* ]]
    then 
        echo
	    echo "Não existe o arquivo $AMBIENTE.tfvars"
        echo
	    exit 1
    fi
}

function valida_account_id() {
    if [ -z "$ACCOUNT_ID" ]
    then
        echo
	    echo 'O arquivo '$AMBIENTE'.tfvars não possui a variável "account_role"'
        echo
	    exit 1
    fi
}
