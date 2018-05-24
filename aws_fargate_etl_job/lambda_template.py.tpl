from __future__ import print_function
import pprint
import boto3

def run_fargate_task(cluster_name, task_arn, task_role_arn, subnet, memory, cpu):
  print("executing ecs fargate task with the following parameters...")
  print("cluster_name: " + cluster_name)
  print("task_arn: " + task_arn)
  print("task_role_arn: " + task_role_arn)
  print("subnet: " + subnet)
  print("memory: " + str(memory))
  print("cpu: " + str(cpu))
  
  client = boto3.client('ecs')
  response = client.run_task(
    cluster=cluster_name,
    taskDefinition=task_arn,
    overrides={
        'taskRoleArn': task_role_arn
    },
    launchType='FARGATE',
    networkConfiguration={
        'awsvpcConfiguration': {
            'subnets': [
                subnet
            ],
            'assignPublicIp': 'ENABLED'
        }
    }
  )
  pp = pprint.PrettyPrinter(indent=4)
  pp.pprint(response)
  return response

def handler(event, context):
  return run_fargate_task(
    "${cluster_name}", 
    "${task_arn}", 
    "${task_role_arn}", 
    "${subnet}", 
    ${memory}, 
    ${cpu}
  )