#!/bin/bash

usage()
{
  cat << EOF
usage: bash ./scripts/packndeploy -n service_name -s stage -p vault_profie_name
-n    | --service_name      (Required)            Service to deploy
-s    | --stage             (Required)            Stage to deploy
-p    | --vault_profile     (Required)            Must use aws-vault profile
-b    | --branch            (Pipeline)            Source branch
-d    | --domain            (Certificate Manager) Requested domain name
-vres | --viewer_response   (CloudFront-UI)       Lambda Function ARN
-vreq | --viewer_request    (CloudFront-UI)       Lambda Function ARN
-r    | --region            (eu-west-1)           Region to deploy
-a    | --app_name          (my-app)              App name
-h    | --help                                    Brings up this menu
EOF
}

infrastructure_folder=aws-resources
stage=
service_name=
s3_temp_bucket=cf-templates-eu-west-1-unfor19
vault_profile=
app_name=ssm-label
region=eu-west-1
branch=
timestamp=$(date '+%Y-%m-%d')
domain=
viewer_response=
viewer_request=

while [ "$1" != "" ]; do
    case $1 in
        -n | --service_name )
            shift
            service_name=$1
        ;;
        -s | --stage )
            shift
            stage=$1
        ;;
        -b | --branch )
            shift
            branch=$1
        ;;
        -p | --vault_profile )
            shift
            vault_profile=$1
        ;;
        -r | --region )
            shift
            region=$1
        ;;
        -a | --app_name )
            shift
            app_name=$1
        ;;
        -d | --domain )
            shift
            domain=$1
        ;;
        -vreq | --viewer_request )
            shift
            viewer_request=$1
        ;;
        -vres | --viewer_response )
            shift
            viewer_response=$1
        ;;                
        -h | --help )             usage
            exit
        ;;
        * )                           usage
            exit 1
    esac
    shift
done

if [ -z $s3_temp_bucket ]; then
    echo "Edit the file ./scripts/packndeploy and set the s3_temp_bucket variable."
    exit
fi

if [ -z $service_name ]; then
    echo "Service name is required, provide it with the flag: -n service_name"
    exit
fi

if [ -z $stage ]; then
    echo "Stage is required, provide it with the flag: -s stage"
    exit
fi

if [ -z $vault_profile ]; then
    echo "Vault Profile is required, provide it with the flag: -p vault_profile_name"
    exit
fi

filename="$service_name.yml"
if [ ! -f "./${infrastructure_folder}/$filename" ]; then
    echo "File does not exist, make sure the service name matches the yml file name."
    exit
fi

is_pipeline=$(echo "$filename" | grep "pipeline-")
is_certificate_manager=$(echo "$filename" | grep "certificatemanager")
is_cloudfrontui=$(echo "$filename" | grep "cloudfront-ui")

if [ ! -z $is_pipeline  ]; then
    if [ -z $branch ]; then
        echo "Branch is required for deploying a pipeline, provide it with the flag: -b branch"
        exit
    fi
fi

if [ ! -z $is_cloudfrontui ]; then
    if [ -z $viewer_request ]; then
        echo "ViewerRequest is required for deploying a cloudfront-ui, provide it with the flag: -vreq lambdaArn"
        exit
    fi
    if [ -z $viewer_response ]; then
        echo "ViewerResponse is required for deploying a cloudfront-ui, provide it with the flag: -vres lambdaArn"
        exit
    fi
fi

rm -f ./scripts/${app_name}-${service_name}-${stage}.template
package=$(aws-vault exec "${vault_profile}" -- aws cloudformation package \
    --template-file "./${infrastructure_folder}/${filename}" \
    --s3-bucket "${s3_temp_bucket}" \
--output-template-file "./scripts/${app_name}-${service_name}-${stage}.template")
package_success=$(echo $package | grep "YOUR STACK NAME")

if [ -z "${package_success}" ]; then
    echo "${package}"
    echo "Failed to create package, fix the above."
    exit
fi

echo "Successfully created the package."