#!/bin/sh
set -e

function usage
{
    echo "Usage: put_params -k keyID -j jsonFile"
    echo "   ";
    echo "  -k | --keyId              : ID of the KMS key you want to use to encrypt the parameter.";
    echo "  -j | --jsonFile           : Location of the json formatted file from which you will read in parameters.";
    echo "  -h | --help               : This message";
    echo "   ";
    echo "Json file should be formatted like this example: { "name":"/online-app-development/APP_ENV", "type":"SecureString", "value":"development" } One Json array per line.";
    echo "   ";
    echo "Type has 3 options: SecureString, StringList, String";
    echo "   ";
}

function parseArgs
{
  # Named args
  while [ "$1" != "" ]; do
      case "$1" in
          -k | --keyId )                keyId="$2";                  shift;;
          -j | --jsonFile )             jsonFile="$2";               shift;;
          * )
      esac
      shift # move to next kv pair
  done

  # Validate required args
  if [[ -z "${keyId}" || -z "${jsonFile}" ]]; then
      echo "Invalid arguments"
      usage
      exit;
  fi
}

#Read in Json file and call putParameters to insert into parameter store.
function parseJsonAndPut
{
  while IFS='' read -r line || [[ -n "$line" ]]; do
    name=`echo $line | jq -r .name`
    type=`echo $line | jq -r .type`
    value=`echo $line | jq -r .value`
    putParameters $name $type $value
  done < "$1"
}

#Put parameters into parameter store. Could write function to get parameters as well.
function putParameters
{
  aws ssm put-parameter --key-id $keyId --name $name --type $type --value $value
}

#Execute
function run
{
  parseArgs $@
  parseJsonAndPut $jsonFile
}



run "$@";
