  
#!/bin/bash
source ./scripts/packonly.sh

echo "Deploying to AWS..."

if [ ! -z $is_pipeline ]; then
    deploy=$(aws-vault exec "${vault_profile}" -- aws cloudformation deploy \
        --capabilities CAPABILITY_IAM \
        --region "${region}" \
        --template-file "./scripts/${app_name}-${service_name}-${stage}.template" \
        --stack-name "${app_name}-${service_name}-${stage}" \
    --parameter-overrides Stage=$stage GithubBranchName=$branch AppName=$app_name)
elif [ ! -z $is_certificate_manager ]; then
        # Certificates are managed in Virginia, for CloudFront
        deploy=$(aws-vault exec "${vault_profile}" -- aws cloudformation deploy \
            --capabilities CAPABILITY_IAM \
            --region "us-east-1" \
            --template-file "./scripts/${app_name}-${service_name}-${stage}.template" \
            --stack-name "${app_name}-${service_name}-${stage}" \
        --parameter-overrides Stage=$stage AppName=$app_name Domain=$domain)
elif [ ! -z $is_cloudfrontui ]; then
    deploy=$(aws-vault exec "${vault_profile}" -- aws cloudformation deploy \
        --capabilities CAPABILITY_IAM \
        --region "${region}" \
        --template-file "./scripts/${app_name}-${service_name}-${stage}.template" \
        --stack-name "${app_name}-${service_name}-${stage}" \
    --parameter-overrides Stage=$stage LambdaEdgeViewerRequestARN=$viewer_request LambdaEdgeViewerResponseARN=$viewer_response AppName=$app_name)        
else
    deploy=$(aws-vault exec "${vault_profile}" -- aws cloudformation deploy \
        --capabilities CAPABILITY_IAM \
        --capabilities CAPABILITY_NAMED_IAM \
        --region "${region}" \
        --template-file "./scripts/${app_name}-${service_name}-${stage}.template" \
        --stack-name "${app_name}-${service_name}-${stage}" \
    --parameter-overrides Stage=$stage Timestamp=$timestamp AppName=$app_name)
fi

echo $deploy

rm -f ./scripts/${app_name}-${service_name}-${stage}.template