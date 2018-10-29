#!/usr/bin/env python
import argparse
import boto3
import sys
from retrying import retry

# FUNCTIONS

'''
Setup command line arguments and return values
'''
def get_arguments():
    parser = argparse.ArgumentParser(description='Run an Ansible playbook using SSM')
    parser.add_argument('playbook', help='Name of a playbook in the ansible directory')
    parser.add_argument('--branch', help='Branch containing the desired playbook. Default: master', default='master', dest='branch')
    parser.add_argument('--names', help='Filter target nodes by name. Comma seperated', dest='names')
    args = parser.parse_args()
    return args

'''
Run an SSM command against the targets
'''
def send_ssm_command(playbook_url, targets):
    send_command_response = ssm_client.send_command(
        # Todo, this by default, named instance if specified
        Targets=[targets],
        DocumentName='AWS-RunAnsiblePlaybook',
        Parameters={
            'playbook': [''],
            'playbookurl': [playbook_url],
            'extravars': ['SSM=True'],
            'check': ['False']
        },
        OutputS3BucketName='gs-infrastructure-output'
    )
    print('Command: {}'.format(send_command_response['Command']['CommandId']))
    return wait_for_ssm_command(command_id=send_command_response['Command']['CommandId'])

'''
Wait for a given SSM command to complete, with incremental backoffs
'''
@retry(
    wait_exponential_multiplier=1000,
    wait_exponential_max=180000 # 3 minutes
)
def wait_for_ssm_command(command_id):
    list_commands_response = ssm_client.list_commands(
        CommandId=command_id
    )
    if list_commands_response['Commands'][0]['Status'] == 'Failed':
        print('State: {}'.format(list_commands_response['Commands'][0]['Status']))
        return False
    elif list_commands_response['Commands'][0]['Status'] != 'Success':
        print('State: {}'.format(list_commands_response['Commands'][0]['Status']))
        raise Exception
    else:
        print('State: {}'.format(list_commands_response['Commands'][0]['Status']))
        return True

# OPERATION

args = get_arguments()
playbook = args.playbook.replace('.yml', '')
targets = {'Key': 'tag:gs:role', 'Values': ['pi']}
if args.names:
    names = args.names.split(',')
    targets = {'Key': 'tag:gs:name', 'Values': names}
ssm_client = boto3.client('ssm')
playbook_url = 'https://raw.githubusercontent.com/daveygit2050/gs-infrastructure/{}/ansible/{}.yml'.format(args.branch, playbook)
print('Running {}'.format(playbook_url))
result = send_ssm_command(playbook_url=playbook_url, targets=targets)
if not result:
    print('Playbook execution failed')
    sys.exit(1)
else:
    print('Playbook execution succeeded')
