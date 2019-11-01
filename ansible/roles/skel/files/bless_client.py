#!/usr/bin/python3

"""bless_client
A sample client to invoke the BLESS Lambda function and save the signed SSH Certificate.

Usage:
  bless_client.py remote_username

  remote_username: user of the instance you wish to log in as
"""
import boto3
import json
import os
import pwd
import socket
import stat
import sys


def main(argv):
    if len(argv) != 1:
        print ('Usage: bless_client.py remote_user_name')
        return -1

    remote_usernames = argv[0]
    region = "ap-south-1"
    lambda_function_name = "BLESS"

    with open(os.path.expanduser("~/.ssh/blessid.pub"), 'r') as f:
        public_key = f.read().strip()
    certificate_filename = os.path.expanduser("~/.ssh/blessid-cert.pub")
    bastion_ip = socket.gethostbyname(socket.gethostname())

    payload = {'bastion_user': 'ec2-user', 'bastion_user_ip': bastion_ip,
               'remote_usernames': remote_usernames, 'bastion_ips': bastion_ip,
               'command': "", 'public_key_to_sign': public_key}

    payload_json = json.dumps(payload)

    print('Executing:')
    print('payload_json is: \'{}\''.format(payload_json))
    lambda_client = boto3.client('lambda', region_name=region)
    response = lambda_client.invoke(FunctionName=lambda_function_name,
                                    InvocationType='RequestResponse', LogType='None',
                                    Payload=payload_json)
    print('{}\n'.format(response['ResponseMetadata']))

    if response['StatusCode'] != 200:
        print ('Error creating cert.')
        return -1

    payload = json.loads(response['Payload'].read())

    if 'certificate' not in payload:
        print(payload)
        return -1

    cert = payload['certificate']

    with os.fdopen(os.open(certificate_filename, os.O_WRONLY | os.O_CREAT, 0o600),
                   'w') as cert_file:
        cert_file.write(cert)

    # If cert_file already existed with the incorrect permissions, fix them.
    file_status = os.stat(certificate_filename)
    if 0o600 != (file_status.st_mode & 0o777):
        os.chmod(certificate_filename, stat.S_IRUSR | stat.S_IWUSR)

    print('Wrote Certificate to: ' + certificate_filename)


if __name__ == '__main__':
    main(sys.argv[1:])
