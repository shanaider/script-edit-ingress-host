#!/bin/bash

# Enter the namespace where the service is deployed
#namespace=drivs
#ingress=app-4pl-reminder-internal  

count_ingress=0;
num_rules=0;
# Loop through all namespaces
for namespace in $(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}'); do
  #Loop through all ingress in the current namespace
  for ingress in $(kubectl get ingress -n $namespace -o jsonpath='{.items[*].metadata.name}'); do

    # Get the number of rules in the Ingress resource
    num_rules=$(kubectl get ingress $ingress -n $namespace -o json | jq '.spec.rules | length')

    # Loop through each rule and patch the host field
    for ((i=0;i<$num_rules;i++))
    do
        # Get the host of the current service in the current namespace
        host=$(kubectl get ingress $ingress -n $namespace -o jsonpath='{.spec.rules['"$i"'].host}')
        
        # Check if the  exists
        if [ -n "$host" ]; then
            # Replace the host if it matches "*.dev.tel.internal"
            new_host="${host//dev.tel.internal/wfm.pt.internal}"
            echo $new_host
            if [ "$new_host" != "$host" ]; then
                kubectl patch ingress $ingress -n $namespace --type=json -p='[{"op": "replace", "path": "/spec/rules/'"$i"'/host", "value": "'"$new_host"'"}]'
                echo -e "Ingress updated for ingress $ingress in namespace $namespace:\n$new_host\n"
            fi
        count_ingress=$(( $count_ingress + 1 ));
        fi
        
    done

  done
done

#Summary
echo -e "Summnary of ingresses: $count_ingress\n"