#!/bin/bash 

bu=$2
BU=${bu^^}

tfvarsfolder="tfvars"

if [[ -n "$BU" ]] && [[ "$BU" == "EMI" ]]; then
    echo "EMI selecionado"
elif [[ -n "$BU" ]] && [[ "$BU" == "ADQ" ]]; then
    echo "ADQ selecionado"
else 
    echo "O parametro bu ou ambiente nao foi especificado corretamente"
fi
source ./utils/validations.sh

ambiente=$1
AMBIENTE=${ambiente^^}
export AMBIENTE

valida_argumento $AMBIENTE
valida_ambiente $AMBIENTE

ACCOUNT_ID=$(cat ./tfvars/$AMBIENTE.tfvars | grep 'account_role' | rev | cut -d: -f2 | rev)
export ACCOUNT_ID

valida_account_id $ACCOUNT_ID

terraform apply -auto-approve -var-file=tfvars/$AMBIENTE".tfvars"