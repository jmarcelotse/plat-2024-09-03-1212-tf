#!/bin/bash

bu=$2
BU=${bu^^}

tfvarsfolder="tfvars"

if [[ -n "$BU" ]] && [[ "$BU" == "EMI" ]]; then
    for file in "${tfvarsfolder}"/ADQ*; do
        filename=$(basename -- "$file")
        rm -- "$file"
    done
    for file in "${tfvarsfolder}"/EMI*; do
        filename=$(basename -- "$file")
        newfilename="${filename:3}"
        mv -- "$file" "${tfvarsfolder}/${newfilename}"
    done
elif [[ -n "$BU" ]] && [[ "$BU" == "ADQ" ]]; then
    for file in "${tfvarsfolder}"/EMI*; do
        filename=$(basename -- "$file")
        rm -- "$file"
    done
    for file in "${tfvarsfolder}"/ADQ*; do
        filename=$(basename -- "$file")
        newfilename="${filename:3}"
        mv -- "$file" "${tfvarsfolder}/${newfilename}"
    done
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

cat ./utils/backend.tf.tpl | ./utils/env-subst.sh > backend.tf

terraform fmt
terraform fmt tfvars/ 
terraform init -reconfigure
terraform plan -var-file=tfvars/$AMBIENTE".tfvars"
