#!/bin/sh

export TF_VAR_postgres_username=$(pass /terraformtest/postgres_username)
export TF_VAR_postgres_password=$(pass /terraformtest/postgres_password)
export TF_VAR_data_encryption_public_rsa_key=$(pass /terraformtest/data_encryption_public_rsa_key)

terraform destroy
