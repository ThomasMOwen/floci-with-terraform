usage="$0 [-h] [-o s] [-f s] -- script to run terraform commands against AWS emulated environment

where:
    -h : show help text
    -o : define the operation to perform. Operations: plan, apply, apply-auto-approve, destroy
    -f : specify the tfvars file to use for the operation"


while getopts o:f:h opt
do
    case "${opt}" in
        o) operation=${OPTARG};;
        f) tfvars=${OPTARG};;
        h) echo "${usage}"
           exit 0;;
    esac
done

if [ -z ${operation} ]; then
    echo "No operation specified. Please specify an operation with -o"
    exit 1
fi

if [ -z ${tfvars} ]; then
    echo "No tfvars file specified. Please specify a tfvars file with -f"
    exit 1
fi

if [ ${operation} == "plan" ]; then
    docker run --rm -it --network=floci-env -v $PWD:/workspace  -w /workspace hashicorp/terraform:latest plan -var-file=${tfvars}
elif [ ${operation} == "apply" ]; then
    docker run --rm -it --network=floci-env -v $PWD:/workspace  -w /workspace hashicorp/terraform:latest apply -var-file=${tfvars}
elif [ ${operation} == "apply-auto-approve" ]; then
    docker run --rm -it --network=floci-env -v $PWD:/workspace  -w /workspace hashicorp/terraform:latest apply -auto-approve -var-file=${tfvars}
elif [ ${operation} == "destroy" ]; then
    docker run --rm -it --network=floci-env -v $PWD:/workspace  -w /workspace hashicorp/terraform:latest destroy -var-file=${tfvars}
else
    echo "Invalid operation specified. Please specify either 'plan' or 'apply' with -o"
    exit 1
fi

